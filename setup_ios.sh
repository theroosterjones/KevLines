#!/bin/bash

# KevLines iOS Setup Script
# This script helps set up the iOS project for development

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  KevLines iOS Setup Script${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_step() {
    echo -e "${YELLOW}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

check_xcode() {
    print_step "Checking Xcode installation..."
    
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed or not in PATH"
        print_info "Please install Xcode from the Mac App Store"
        print_info "After installation, run: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
        exit 1
    fi
    
    XCODE_VERSION=$(xcodebuild -version | head -n 1)
    print_success "Found $XCODE_VERSION"
}

check_project() {
    print_step "Checking project structure..."
    
    if [ ! -d "KevLines.xcodeproj" ]; then
        print_error "Xcode project not found"
        exit 1
    fi
    
    if [ ! -f "KevLines/KevLinesApp.swift" ]; then
        print_error "Main app file not found"
        exit 1
    fi
    
    print_success "Project structure looks good"
}

setup_permissions() {
    print_step "Setting up app permissions..."
    
    # Check if Info.plist exists, if not, create one
    if [ ! -f "KevLines/Info.plist" ]; then
        print_info "Creating Info.plist with required permissions..."
        cat > KevLines/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSCameraUsageDescription</key>
    <string>KevLines needs camera access to analyze your workout form and provide real-time feedback.</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>KevLines may use microphone access for audio feedback during workouts.</string>
    <key>CFBundleDisplayName</key>
    <string>KevLines</string>
    <key>CFBundleIdentifier</key>
    <string>com.kevlines.app</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>UILaunchScreen</key>
    <dict/>
    <key>UIRequiredDeviceCapabilities</key>
    <array>
        <string>armv7</string>
    </array>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
EOF
        print_success "Info.plist created"
    else
        print_success "Info.plist already exists"
    fi
}

build_simulator() {
    print_step "Building for iOS Simulator..."
    
    xcodebuild build \
        -project "KevLines.xcodeproj" \
        -scheme "KevLines" \
        -configuration Debug \
        -destination "platform=iOS Simulator,name=iPhone 15,OS=latest" \
        -derivedDataPath build
    
    print_success "Simulator build completed"
}

open_simulator() {
    print_step "Opening iOS Simulator..."
    open -a Simulator
    print_success "Simulator opened"
}

show_next_steps() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Next Steps${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "1. Open the project in Xcode:"
    echo "   open KevLines.xcodeproj"
    echo ""
    echo "2. Configure signing in Xcode:"
    echo "   - Select the KevLines project"
    echo "   - Go to 'Signing & Capabilities'"
    echo "   - Select your development team"
    echo ""
    echo "3. Connect your iPhone and deploy:"
    echo "   - Select your device in Xcode"
    echo "   - Press Cmd+R to build and run"
    echo ""
    echo "4. Trust the developer on your iPhone:"
    echo "   Settings → General → VPN & Device Management"
    echo ""
    echo "For detailed instructions, see: IOS_DEPLOYMENT_GUIDE.md"
    echo ""
}

main() {
    print_header
    
    check_xcode
    check_project
    setup_permissions
    
    echo ""
    print_info "Would you like to build for simulator? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        build_simulator
        echo ""
        print_info "Would you like to open the simulator? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            open_simulator
        fi
    fi
    
    show_next_steps
}

main "$@"
