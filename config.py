import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Microsoft Authentication Settings
MICROSOFT_CLIENT_ID = os.getenv('MICROSOFT_CLIENT_ID')
MICROSOFT_CLIENT_SECRET = os.getenv('MICROSOFT_CLIENT_SECRET')
MICROSOFT_TENANT_ID = os.getenv('MICROSOFT_TENANT_ID', 'common')
MICROSOFT_SCOPE = ['https://graph.microsoft.com/.default']

# Pushover Notification Settings
PUSHOVER_API_TOKEN = os.getenv('PUSHOVER_API_TOKEN')
PUSHOVER_USER_KEY = os.getenv('PUSHOVER_USER_KEY')

# Application Settings
CHECK_INTERVAL = 300  # Check for new entries every 5 minutes
MAX_RETRIES = 3  # Maximum number of retries for failed requests
RETRY_DELAY = 60  # Delay between retries in seconds

# Food Diary API Settings
FOOD_DIARY_API_URL = os.getenv('FOOD_DIARY_API_URL')
API_VERSION = 'v1.0'

# Logging Settings
LOG_LEVEL = 'INFO'
LOG_FILE = 'food_diary_notifier.log' 