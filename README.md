# Food Diary Notifier

This application monitors food diary entries from a web interface and sends real-time notifications to your iPhone when clients make new entries.

## Features
- Microsoft authentication for secure access
- Real-time monitoring of food diary entries
- Push notifications to iPhone using Pushover
- Configurable monitoring intervals

## Setup
1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Create a `.env` file with the following variables:
   ```
   MICROSOFT_CLIENT_ID=your_client_id
   MICROSOFT_CLIENT_SECRET=your_client_secret
   PUSHOVER_API_TOKEN=your_pushover_token
   PUSHOVER_USER_KEY=your_pushover_user_key
   ```

3. Configure the application settings in `config.py`

4. Run the application:
   ```bash
   python main.py
   ```

## Requirements
- Python 3.8+
- Microsoft Azure AD application registration
- Pushover account and app token
- Internet connection

## Security
- All credentials are stored in environment variables
- Uses Microsoft's secure authentication
- HTTPS for all communications 