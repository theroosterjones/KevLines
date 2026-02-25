#!/bin/bash

echo "🚀 Resuming KevLines iPhone Testing..."
echo "======================================"

# Check if we're in the right directory
if [ ! -f "app.py" ]; then
    echo "❌ Please run this script from the KevLines directory"
    exit 1
fi

# Start Python backend
echo "🐍 Starting Python backend..."
python3 app.py &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Check if backend is running
if curl -s http://localhost:3000/api/status > /dev/null; then
    echo "✅ Backend is running on localhost:3000"
else
    echo "❌ Backend failed to start"
    exit 1
fi

# Open Xcode project
echo "📱 Opening Xcode project..."
open KevLines/KevLines.xcodeproj

echo ""
echo "🎯 Ready for testing!"
echo "1. Connect your iPhone via USB"
echo "2. Select iPhone as target device in Xcode"
echo "3. Build and run (Cmd + R)"
echo ""
echo "🛑 To stop: Press Ctrl+C or run 'pkill -f python3 app.py'"
echo ""

# Keep script running so backend stays alive
wait $BACKEND_PID

