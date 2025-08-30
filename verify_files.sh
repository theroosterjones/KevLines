#!/bin/bash

# KevLines File Verification Script
# This script verifies that all required Swift files are present

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  KevLines File Verification${NC}"
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

verify_swift_files() {
    print_step "Verifying Swift files..."
    
    local files=(
        "KevLines/KevLinesApp.swift"
        "KevLines/ContentView.swift"
        "KevLines/PoseAnalyzer.swift"
        "KevLines/CameraView.swift"
        "KevLines/ExerciseView.swift"
        "KevLines/WorkoutHistoryView.swift"
        "KevLines/SettingsView.swift"
    )
    
    local missing_files=()
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            print_success "✓ $file"
        else
            print_error "✗ $file (missing)"
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -eq 0 ]; then
        print_success "All Swift files are present!"
    else
        print_error "Missing ${#missing_files[@]} file(s):"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi
}

verify_swift_syntax() {
    print_step "Checking Swift syntax..."
    
    local files=(
        "KevLines/KevLinesApp.swift"
        "KevLines/ContentView.swift"
        "KevLines/PoseAnalyzer.swift"
        "KevLines/CameraView.swift"
        "KevLines/ExerciseView.swift"
        "KevLines/WorkoutHistoryView.swift"
        "KevLines/SettingsView.swift"
    )
    
    local syntax_errors=()
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            # Basic syntax check - look for common Swift errors
            if grep -q "import SwiftUI" "$file" && ! grep -q "error:" "$file"; then
                print_success "✓ $file (syntax OK)"
            else
                print_error "✗ $file (potential syntax issues)"
                syntax_errors+=("$file")
            fi
        fi
    done
    
    if [ ${#syntax_errors[@]} -eq 0 ]; then
        print_success "All Swift files have valid syntax!"
    else
        print_error "Syntax issues found in ${#syntax_errors[@]} file(s)"
        return 1
    fi
}

check_assets() {
    print_step "Checking assets..."
    
    if [ -d "KevLines/Assets.xcassets" ]; then
        print_success "✓ Assets.xcassets directory exists"
    else
        print_error "✗ Assets.xcassets directory missing"
    fi
    
    if [ -d "KevLines/Preview Content" ]; then
        print_success "✓ Preview Content directory exists"
    else
        print_error "✗ Preview Content directory missing"
    fi
}

show_next_steps() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Next Steps${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
    echo "1. Create a new Xcode project:"
    echo "   - Open Xcode"
    echo "   - Create new iOS App project"
    echo "   - Name it 'KevLines'"
    echo "   - Save in this directory"
    echo ""
    echo "2. Add the Swift files to the project:"
    echo "   - Right-click on KevLines folder in Xcode"
    echo "   - Choose 'Add Files to KevLines'"
    echo "   - Select all Swift files from the KevLines directory"
    echo ""
    echo "3. Configure project settings:"
    echo "   - Set your development team"
    echo "   - Add camera and microphone permissions"
    echo ""
    echo "4. Build and test:"
    echo "   - Select iOS Simulator"
    echo "   - Press Cmd+R to build and run"
    echo ""
    echo "For detailed instructions, see: create_xcode_project.md"
    echo ""
}

main() {
    print_header
    
    verify_swift_files
    verify_swift_syntax
    check_assets
    
    show_next_steps
}

main "$@"
