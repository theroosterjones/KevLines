import logging
import time
import schedule
from datetime import datetime
import msal
import requests
from pushover import Client as PushoverClient
import config

# Configure logging
logging.basicConfig(
    level=getattr(logging, config.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(config.LOG_FILE),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

class FoodDiaryNotifier:
    def __init__(self):
        self.access_token = None
        self.last_check_time = None
        self.pushover_client = PushoverClient(config.PUSHOVER_USER_KEY, api_token=config.PUSHOVER_API_TOKEN)
        
    def get_microsoft_token(self):
        """Get Microsoft authentication token"""
        try:
            app = msal.ConfidentialClientApplication(
                config.MICROSOFT_CLIENT_ID,
                authority=f"https://login.microsoftonline.com/{config.MICROSOFT_TENANT_ID}",
                client_credential=config.MICROSOFT_CLIENT_SECRET
            )
            
            result = app.acquire_token_for_client(scopes=config.MICROSOFT_SCOPE)
            
            if "access_token" in result:
                self.access_token = result["access_token"]
                logger.info("Successfully obtained Microsoft authentication token")
                return True
            else:
                logger.error(f"Failed to obtain token: {result.get('error')}")
                return False
                
        except Exception as e:
            logger.error(f"Error getting Microsoft token: {str(e)}")
            return False

    def check_new_entries(self):
        """Check for new food diary entries"""
        if not self.access_token:
            if not self.get_microsoft_token():
                return

        try:
            headers = {
                'Authorization': f'Bearer {self.access_token}',
                'Content-Type': 'application/json'
            }
            
            # Get current time for comparison
            current_time = datetime.utcnow()
            
            # Make API request to get new entries
            response = requests.get(
                f"{config.FOOD_DIARY_API_URL}/entries",
                headers=headers,
                params={
                    'since': self.last_check_time.isoformat() if self.last_check_time else None
                }
            )
            
            if response.status_code == 200:
                entries = response.json()
                
                for entry in entries:
                    # Send notification for each new entry
                    self.send_notification(entry)
                
                self.last_check_time = current_time
                logger.info(f"Successfully checked for new entries at {current_time}")
                
            elif response.status_code == 401:
                # Token expired, get new token
                logger.info("Token expired, requesting new token")
                self.get_microsoft_token()
                
            else:
                logger.error(f"API request failed with status code: {response.status_code}")
                
        except Exception as e:
            logger.error(f"Error checking for new entries: {str(e)}")

    def send_notification(self, entry):
        """Send notification to iPhone using Pushover"""
        try:
            # Format the notification message
            message = f"New food diary entry from {entry.get('client_name', 'Unknown')}:\n"
            message += f"Time: {entry.get('timestamp', 'Unknown')}\n"
            message += f"Food: {entry.get('food_item', 'Unknown')}\n"
            message += f"Calories: {entry.get('calories', 'Unknown')}"
            
            # Send notification
            self.pushover_client.send_message(
                message,
                title="New Food Diary Entry"
            )
            
            logger.info(f"Notification sent for entry from {entry.get('client_name', 'Unknown')}")
            
        except Exception as e:
            logger.error(f"Error sending notification: {str(e)}")

    def run(self):
        """Run the notification service"""
        logger.info("Starting Food Diary Notifier service")
        
        # Schedule the check_new_entries function to run every CHECK_INTERVAL seconds
        schedule.every(config.CHECK_INTERVAL).seconds.do(self.check_new_entries)
        
        # Run immediately on startup
        self.check_new_entries()
        
        # Keep the script running
        while True:
            schedule.run_pending()
            time.sleep(1)

if __name__ == "__main__":
    notifier = FoodDiaryNotifier()
    notifier.run() 