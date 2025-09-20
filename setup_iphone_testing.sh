#!/bin/bash

echo "🍎 Setting up KevLines for iPhone testing..."

# Get the local IP address
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo "🌐 Your local IP address is: $LOCAL_IP"
echo "📱 Update the baseURL in APIService.swift to: http://$LOCAL_IP:3000"

# Check if Python backend is running
echo "🔍 Checking if Python backend is running..."
if curl -s http://localhost:3000/api/status > /dev/null; then
    echo "✅ Backend is running on localhost:3000"
else
    echo "❌ Backend is not running. Please start it with: python app.py"
fi

# Create test video directory if it doesn't exist
mkdir -p test_videos

echo ""
echo "📋 iPhone Testing Checklist:"
echo "1. ✅ Update APIService.swift baseURL to: http://$LOCAL_IP:3000"
echo "2. ✅ Start Python backend: python app.py"
echo "3. ✅ Ensure iPhone and computer are on same WiFi network"
echo "4. ✅ Build and run app on iPhone device (not simulator)"
echo "5. ✅ Test video upload from Photos library"
echo "6. ✅ Test video analysis and download"
echo ""
echo "🔧 Troubleshooting:"
echo "- If connection fails, check firewall settings"
echo "- Ensure port 3000 is not blocked"
echo "- Try disabling VPN if connected"
echo "- Check that both devices are on the same network"
