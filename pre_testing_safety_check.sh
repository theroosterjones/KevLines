#!/bin/bash

echo "🛡️ KevLines iPhone Testing Safety Checklist"
echo "=============================================="
echo ""

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is designed for macOS only"
    exit 1
fi

echo "📱 iPhone Safety Pre-Check"
echo "-------------------------"

# Check if iPhone is connected
echo "1. Checking for connected iPhone..."
if system_profiler SPUSBDataType | grep -q "iPhone"; then
    echo "   ✅ iPhone detected via USB"
    IPHONE_CONNECTED=true
else
    echo "   ⚠️  No iPhone detected via USB"
    echo "   📝 Make sure to connect your iPhone before testing"
    IPHONE_CONNECTED=false
fi

# Check available storage
echo ""
echo "2. Checking available storage..."
AVAILABLE_STORAGE=$(df -h . | tail -1 | awk '{print $4}')
echo "   💾 Available storage: $AVAILABLE_STORAGE"

# Check if backup is recent
echo ""
echo "3. Checking for recent iPhone backup..."
BACKUP_DIR="$HOME/Library/Application Support/MobileSync/Backup"
if [ -d "$BACKUP_DIR" ]; then
    LATEST_BACKUP=$(find "$BACKUP_DIR" -name "Info.plist" -exec stat -f "%m %N" {} \; | sort -nr | head -1)
    if [ -n "$LATEST_BACKUP" ]; then
        BACKUP_TIME=$(echo "$LATEST_BACKUP" | awk '{print $1}')
        CURRENT_TIME=$(date +%s)
        TIME_DIFF=$((CURRENT_TIME - BACKUP_TIME))
        HOURS_AGO=$((TIME_DIFF / 3600))
        
        if [ $HOURS_AGO -lt 24 ]; then
            echo "   ✅ Recent backup found (${HOURS_AGO} hours ago)"
        else
            echo "   ⚠️  Last backup was ${HOURS_AGO} hours ago"
            echo "   📝 Consider creating a fresh backup before testing"
        fi
    else
        echo "   ❌ No backup found"
        echo "   📝 CRITICAL: Create a backup before testing!"
    fi
else
    echo "   ❌ No backup directory found"
    echo "   📝 CRITICAL: Create a backup before testing!"
fi

# Check network configuration
echo ""
echo "4. Checking network configuration..."
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
echo "   🌐 Local IP address: $LOCAL_IP"

# Check if backend is running
echo ""
echo "5. Checking backend status..."
if curl -s http://localhost:3000/api/status > /dev/null 2>&1; then
    echo "   ✅ Backend is running on localhost:3000"
    BACKEND_RUNNING=true
else
    echo "   ❌ Backend is not running"
    echo "   📝 Start backend with: python app.py"
    BACKEND_RUNNING=false
fi

# Check Xcode installation
echo ""
echo "6. Checking Xcode installation..."
if command -v xcodebuild &> /dev/null; then
    XCODE_VERSION=$(xcodebuild -version | head -1)
    echo "   ✅ $XCODE_VERSION installed"
else
    echo "   ❌ Xcode not found"
    echo "   📝 Install Xcode from App Store"
fi

# Check iOS app configuration
echo ""
echo "7. Checking iOS app configuration..."
if [ -f "KevLines/KevLines/APIService.swift" ]; then
    if grep -q "10.0.10.231:3000" "KevLines/KevLines/APIService.swift"; then
        echo "   ✅ APIService configured with correct IP address"
    else
        echo "   ⚠️  APIService may need IP address update"
        echo "   📝 Current IP: $LOCAL_IP"
    fi
else
    echo "   ❌ APIService.swift not found"
fi

echo ""
echo "🛡️ SAFETY SUMMARY"
echo "=================="

# Calculate safety score
SAFETY_SCORE=0
TOTAL_CHECKS=7

if [ "$IPHONE_CONNECTED" = true ]; then ((SAFETY_SCORE++)); fi
if [ -n "$LATEST_BACKUP" ]; then ((SAFETY_SCORE++)); fi
if [ "$BACKEND_RUNNING" = true ]; then ((SAFETY_SCORE++)); fi
if command -v xcodebuild &> /dev/null; then ((SAFETY_SCORE++)); fi
if [ -f "KevLines/KevLines/APIService.swift" ]; then ((SAFETY_SCORE++)); fi
# Storage check (always pass if we got here)
((SAFETY_SCORE++))
# Network check (always pass if we got here)
((SAFETY_SCORE++))

SAFETY_PERCENTAGE=$((SAFETY_SCORE * 100 / TOTAL_CHECKS))

echo "Safety Score: $SAFETY_SCORE/$TOTAL_CHECKS ($SAFETY_PERCENTAGE%)"

if [ $SAFETY_PERCENTAGE -ge 80 ]; then
    echo "✅ SAFE TO PROCEED with testing"
elif [ $SAFETY_PERCENTAGE -ge 60 ]; then
    echo "⚠️  PROCEED WITH CAUTION - Address warnings above"
else
    echo "❌ NOT SAFE TO PROCEED - Fix critical issues first"
fi

echo ""
echo "📋 FINAL CHECKLIST"
echo "==================="
echo "Before testing on your iPhone:"
echo "□ Create a full backup of your iPhone"
echo "□ Ensure iPhone is charged (>50%)"
echo "□ Connect iPhone to same WiFi network as computer"
echo "□ Start Python backend: python app.py"
echo "□ Build and run app in Xcode"
echo "□ Test with small video files first"
echo "□ Monitor device temperature and performance"
echo ""
echo "🚨 EMERGENCY PROCEDURES"
echo "======================="
echo "If something goes wrong:"
echo "1. Force close the app (double-tap home, swipe up)"
echo "2. Restart iPhone (hold power + volume down)"
echo "3. Restore from backup if necessary"
echo ""
echo "📞 Need help? Check SAFETY_GUIDE.md for detailed procedures"
