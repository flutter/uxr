#!/bin/bash

# Flutter Universal Installer Launcher
# This script detects the operating system and runs the appropriate Flutter installer
# Run with: bash install-flutter.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to detect operating system
detect_os() {
    local os=""
    local arch=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        os="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="macos"
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        os="windows"
    else
        os="unknown"
    fi
    
    arch=$(uname -m 2>/dev/null || echo "unknown")
    
    echo "$os:$arch"
}

# Function to download script if not present
download_script() {
    local script_name=$1
    local script_url="https://raw.githubusercontent.com/flutter/uxr/master/$script_name"
    
    if [[ ! -f "$script_name" ]]; then
        print_color $BLUE "Downloading $script_name..."
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL "$script_url" -o "$script_name"
        elif command -v wget >/dev/null 2>&1; then
            wget -q "$script_url" -O "$script_name"
        else
            print_color $RED "✗ Neither curl nor wget found. Cannot download installer script."
            print_color $YELLOW "Please install curl or wget, or download the script manually:"
            print_color $YELLOW "  $script_url"
            exit 1
        fi
        
        chmod +x "$script_name"
        print_color $GREEN "✓ Downloaded $script_name"
    fi
}

# Function to show usage
print_usage() {
    echo "Flutter Universal Installer"
    echo "=========================="
    echo ""
    echo "This script automatically detects your operating system and runs"
    echo "the appropriate Flutter installation script."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options are passed through to the platform-specific installer:"
    echo "  -p, --path PATH          Installation path"
    echo "  -c, --channel CHANNEL    Flutter channel (stable, beta, dev)"
    echo "  --no-path               Don't add Flutter to PATH"
    echo "  -v, --verbose           Verbose output"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Platform-specific options:"
    echo "  Linux/macOS:"
    echo "    --skip-android-studio   Skip Android Studio prompts"
    echo "  macOS:"
    echo "    --skip-xcode           Skip Xcode installation prompts"
    echo "  Windows:"
    echo "    --skip-android-studio   Skip Android Studio prompts"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Install with defaults"
    echo "  $0 --path ~/development/flutter      # Custom installation path"
    echo "  $0 --channel beta --verbose          # Beta channel with verbose output"
    echo ""
    echo "For more detailed options, run the platform-specific installer directly:"
    echo "  • Windows: powershell -ExecutionPolicy Bypass -File install-flutter-windows.ps1 -h"
    echo "  • Linux:   bash install-flutter-linux.sh -h"
    echo "  • macOS:   bash install-flutter-macos.sh -h"
}

# Main function
main() {
    # Check for help flag
    for arg in "$@"; do
        if [[ "$arg" == "-h" ]] || [[ "$arg" == "--help" ]]; then
            print_usage
            exit 0
        fi
    done
    
    print_color $GREEN "🚀 Flutter Universal Installer"
    print_color $GREEN "=============================="
    
    # Detect operating system
    local os_info=$(detect_os)
    local os=$(echo "$os_info" | cut -d: -f1)
    local arch=$(echo "$os_info" | cut -d: -f2)
    
    print_color $BLUE "Detected OS: $os ($arch)"
    
    case $os in
        "linux")
            print_color $BLUE "Running Linux installer..."
            download_script "install-flutter-linux.sh"
            bash install-flutter-linux.sh "$@"
            ;;
        "macos")
            print_color $BLUE "Running macOS installer..."
            download_script "install-flutter-macos.sh"
            bash install-flutter-macos.sh "$@"
            ;;
        "windows")
            print_color $BLUE "Running Windows installer..."
            print_color $YELLOW "Note: For Windows, please run the PowerShell script directly:"
            print_color $YELLOW "  powershell -ExecutionPolicy Bypass -File install-flutter-windows.ps1"
            print_color $YELLOW ""
            print_color $YELLOW "Or download it from:"
            print_color $YELLOW "  https://raw.githubusercontent.com/flutter/uxr/master/install-flutter-windows.ps1"
            exit 1
            ;;
        "unknown")
            print_color $RED "✗ Unsupported operating system: $OSTYPE"
            print_color $YELLOW "Supported platforms:"
            print_color $YELLOW "  • Linux (various distributions)"
            print_color $YELLOW "  • macOS (10.14 or later)"
            print_color $YELLOW "  • Windows (PowerShell script available separately)"
            print_color $YELLOW ""
            print_color $YELLOW "For manual installation, visit: https://docs.flutter.dev/get-started/install"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"