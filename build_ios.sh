#!/bin/bash

# KevLines iOS Build Script
# This script helps build and deploy the KevLines iOS app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="KevLines"
SCHEME_NAME="KevLines"
BUNDLE_ID="com.kevlines.app"
TEAM_ID="" # Add your team ID here
PROVISIONING_PROFILE="" # Add your provisioning profile name here

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  KevLines iOS Build Script${NC}"
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

check_prerequisites() {
    print_step "Checking prerequisites..."
    
    # Check if Xcode is installed
    if ! command -v xcodebuild &> /dev/null; then
        print_error "Xcode is not installed or not in PATH"
        exit 1
    fi
    
    # Check if project exists
    if [ ! -d "${PROJECT_NAME}.xcodeproj" ]; then
        print_error "Xcode project not found: ${PROJECT_NAME}.xcodeproj"
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

clean_build() {
    print_step "Cleaning build directory..."
    xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" -configuration Release
    print_success "Build directory cleaned"
}

build_simulator() {
    print_step "Building for iOS Simulator..."
    xcodebuild build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration Debug \
        -destination "platform=iOS Simulator,name=iPhone 16,OS=18.6" \
        -derivedDataPath build
    
    print_success "Simulator build completed"
}

build_device() {
    print_step "Building for iOS Device..."
    
    if [ -z "$TEAM_ID" ]; then
        print_error "TEAM_ID not set. Please add your team ID to the script."
        exit 1
    fi
    
    xcodebuild build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -destination "generic/platform=iOS" \
        -derivedDataPath build \
        CODE_SIGN_IDENTITY="iPhone Developer" \
        DEVELOPMENT_TEAM="${TEAM_ID}" \
        PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}"
    
    print_success "Device build completed"
}

create_archive() {
    print_step "Creating archive..."
    
    if [ -z "$TEAM_ID" ]; then
        print_error "TEAM_ID not set. Please add your team ID to the script."
        exit 1
    fi
    
    xcodebuild archive \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -archivePath "build/${PROJECT_NAME}.xcarchive" \
        -derivedDataPath build \
        CODE_SIGN_IDENTITY="iPhone Developer" \
        DEVELOPMENT_TEAM="${TEAM_ID}" \
        PRODUCT_BUNDLE_IDENTIFIER="${BUNDLE_ID}"
    
    print_success "Archive created: build/${PROJECT_NAME}.xcarchive"
}

export_ipa() {
    print_step "Exporting IPA..."
    
    if [ ! -d "build/${PROJECT_NAME}.xcarchive" ]; then
        print_error "Archive not found. Run create_archive first."
        exit 1
    fi
    
    # Create export options plist
    cat > build/exportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>compileBitcode</key>
    <false/>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
</dict>
</plist>
EOF
    
    xcodebuild -exportArchive \
        -archivePath "build/${PROJECT_NAME}.xcarchive" \
        -exportPath "build/export" \
        -exportOptionsPlist "build/exportOptions.plist"
    
    print_success "IPA exported: build/export/${PROJECT_NAME}.ipa"
}

run_tests() {
    print_step "Running tests..."
    xcodebuild test \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -destination "platform=iOS Simulator,name=iPhone 16,OS=18.6" \
        -derivedDataPath build
    
    print_success "Tests completed"
}

install_simulator() {
    print_step "Installing on iOS Simulator..."
    
    # Find the built app
    APP_PATH=$(find build -name "*.app" -type d | head -1)
    
    if [ -z "$APP_PATH" ]; then
        print_error "No .app bundle found. Run build_simulator first."
        exit 1
    fi
    
    # Install on simulator
    xcrun simctl install booted "$APP_PATH"
    
    print_success "App installed on simulator"
}

open_simulator() {
    print_step "Opening iOS Simulator..."
    open -a Simulator
    print_success "Simulator opened"
}

show_help() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  clean       - Clean build directory"
    echo "  build       - Build for iOS Simulator"
    echo "  device      - Build for iOS Device"
    echo "  archive     - Create archive for distribution"
    echo "  export      - Export IPA from archive"
    echo "  test        - Run tests"
    echo "  install     - Install on iOS Simulator"
    echo "  simulator   - Open iOS Simulator"
    echo "  all         - Clean, build, test, and install"
    echo "  help        - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build        # Build for simulator"
    echo "  $0 all          # Complete build and install"
    echo "  $0 archive      # Create distribution archive"
}

# Main script
main() {
    print_header
    
    case "${1:-help}" in
        "clean")
            check_prerequisites
            clean_build
            ;;
        "build")
            check_prerequisites
            clean_build
            build_simulator
            ;;
        "device")
            check_prerequisites
            clean_build
            build_device
            ;;
        "archive")
            check_prerequisites
            clean_build
            create_archive
            ;;
        "export")
            export_ipa
            ;;
        "test")
            check_prerequisites
            run_tests
            ;;
        "install")
            install_simulator
            ;;
        "simulator")
            open_simulator
            ;;
        "all")
            check_prerequisites
            clean_build
            build_simulator
            run_tests
            install_simulator
            open_simulator
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"



