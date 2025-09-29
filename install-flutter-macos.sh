#!/bin/bash

# Flutter Automated Installation Script for macOS
# This script automates the Flutter SDK installation process on macOS
# Run with: bash install-flutter-macos.sh

set -e  # Exit on any error

# Default configuration
INSTALL_PATH="$HOME/flutter"
CHANNEL="stable"
ADD_TO_PATH=true
SKIP_XCODE=false
VERBOSE=false

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

# Function to print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -p, --path PATH          Installation path (default: $HOME/flutter)"
    echo "  -c, --channel CHANNEL    Flutter channel: stable, beta, dev (default: stable)"
    echo "  --no-path               Don't add Flutter to PATH"
    echo "  --skip-xcode            Skip Xcode installation prompts"
    echo "  -v, --verbose           Verbose output"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --path /usr/local/flutter --channel beta"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            INSTALL_PATH="$2"
            shift 2
            ;;
        -c|--channel)
            CHANNEL="$2"
            shift 2
            ;;
        --no-path)
            ADD_TO_PATH=false
            shift
            ;;
        --skip-xcode)
            SKIP_XCODE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check macOS version
check_macos_version() {
    local version=$(sw_vers -productVersion)
    local major=$(echo $version | cut -d. -f1)
    local minor=$(echo $version | cut -d. -f2)
    
    print_color $BLUE "macOS Version: $version"
    
    # Check if macOS version is supported (10.14 or later)
    if [[ $major -lt 10 ]] || [[ $major -eq 10 && $minor -lt 14 ]]; then
        print_color $RED "✗ Flutter requires macOS 10.14 (Mojave) or later"
        print_color $RED "  Your version: $version"
        exit 1
    fi
    
    print_color $GREEN "✓ macOS version is supported"
}

# Function to install Homebrew if not present
install_homebrew() {
    if command_exists brew; then
        print_color $GREEN "✓ Homebrew is already installed"
        return 0
    fi
    
    print_color $BLUE "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    if command_exists brew; then
        print_color $GREEN "✓ Homebrew installed successfully!"
        return 0
    else
        print_color $RED "✗ Homebrew installation failed"
        return 1
    fi
}

# Function to install dependencies using Homebrew
install_dependencies() {
    print_color $BLUE "Installing system dependencies..."
    
    # Update Homebrew
    brew update
    
    # Install required tools
    local tools=("git" "curl" "unzip")
    
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_color $GREEN "✓ $tool is already installed"
        else
            print_color $BLUE "Installing $tool..."
            brew install "$tool"
        fi
    done
    
    print_color $GREEN "✓ Dependencies installed successfully!"
}

# Function to check Xcode installation
check_xcode() {
    if [[ "$SKIP_XCODE" == true ]]; then
        print_color $YELLOW "⚠️  Skipping Xcode check (iOS development will not be available)"
        return 0
    fi
    
    print_color $BLUE "Checking Xcode installation..."
    
    if command_exists xcodebuild; then
        local xcode_version=$(xcodebuild -version | head -n1)
        print_color $GREEN "✓ Xcode is installed: $xcode_version"
        
        # Check if command line tools are installed
        if xcode-select -p >/dev/null 2>&1; then
            print_color $GREEN "✓ Xcode command line tools are installed"
        else
            print_color $YELLOW "Installing Xcode command line tools..."
            xcode-select --install
            print_color $YELLOW "Please complete the Xcode command line tools installation and re-run this script"
            exit 1
        fi
    else
        print_color $YELLOW "⚠️  Xcode not found. iOS development will not be available."
        print_color $YELLOW "   Install Xcode from the App Store for iOS development"
        
        # Try to install command line tools
        if ! command_exists git; then
            print_color $BLUE "Installing Xcode command line tools..."
            xcode-select --install
            print_color $YELLOW "Please complete the installation and re-run this script"
            exit 1
        fi
    fi
}

# Function to download and install Flutter
install_flutter() {
    print_color $BLUE "Starting Flutter installation..."
    print_color $BLUE "Installation path: $INSTALL_PATH"
    print_color $BLUE "Channel: $CHANNEL"
    
    # Create installation directory
    mkdir -p "$(dirname "$INSTALL_PATH")"
    
    # Remove existing installation if present
    if [[ -d "$INSTALL_PATH" ]]; then
        print_color $YELLOW "Existing Flutter installation found. Removing..."
        rm -rf "$INSTALL_PATH"
    fi
    
    # Determine architecture
    local arch=$(uname -m)
    local flutter_arch=""
    
    if [[ "$arch" == "arm64" ]]; then
        flutter_arch="arm64"
        print_color $BLUE "Detected Apple Silicon (M1/M2) Mac"
    else
        flutter_arch="x64"
        print_color $BLUE "Detected Intel Mac"
    fi
    
    # Download Flutter SDK
    local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/$CHANNEL/macos/flutter_macos_${flutter_arch}_3.16.0-$CHANNEL.zip"
    local flutter_archive="/tmp/flutter_macos.zip"
    
    print_color $BLUE "Downloading Flutter SDK for $flutter_arch..."
    if curl -L "$flutter_url" -o "$flutter_archive"; then
        print_color $GREEN "✓ Flutter SDK downloaded successfully!"
    else
        print_color $RED "✗ Failed to download Flutter SDK"
        return 1
    fi
    
    # Extract Flutter SDK
    print_color $BLUE "Extracting Flutter SDK..."
    if unzip -q "$flutter_archive" -d "$(dirname "$INSTALL_PATH")"; then
        print_color $GREEN "✓ Flutter SDK extracted successfully!"
        rm -f "$flutter_archive"
    else
        print_color $RED "✗ Failed to extract Flutter SDK"
        return 1
    fi
    
    return 0
}

# Function to add Flutter to PATH
add_to_path() {
    local flutter_bin="$INSTALL_PATH/bin"
    local shell_rc=""
    
    # Determine shell configuration file
    if [[ -n "$ZSH_VERSION" ]] || [[ "$SHELL" == */zsh ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]] || [[ "$SHELL" == */bash ]]; then
        shell_rc="$HOME/.bash_profile"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Check if Flutter is already in PATH
    if echo "$PATH" | grep -q "$flutter_bin"; then
        print_color $GREEN "✓ Flutter is already in PATH"
        return 0
    fi
    
    print_color $BLUE "Adding Flutter to PATH in $shell_rc..."
    
    # Create shell config file if it doesn't exist
    touch "$shell_rc"
    
    # Add Flutter to PATH
    echo "" >> "$shell_rc"
    echo "# Flutter SDK" >> "$shell_rc"
    echo "export PATH=\"\$PATH:$flutter_bin\"" >> "$shell_rc"
    
    # Update current session PATH
    export PATH="$PATH:$flutter_bin"
    
    print_color $GREEN "✓ Flutter added to PATH successfully!"
    print_color $YELLOW "Note: Restart your terminal or run 'source $shell_rc' to apply changes"
}

# Function to configure iOS development
configure_ios_development() {
    if [[ "$SKIP_XCODE" == true ]]; then
        return 0
    fi
    
    print_color $BLUE "Configuring iOS development..."
    
    # Accept Xcode license if needed
    if command_exists xcodebuild; then
        if ! xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
            print_color $YELLOW "Xcode license needs to be accepted..."
            sudo xcodebuild -license accept
        fi
        
        print_color $GREEN "✓ iOS development configured"
    fi
}

# Function to install CocoaPods
install_cocoapods() {
    if command_exists pod; then
        print_color $GREEN "✓ CocoaPods is already installed"
        return 0
    fi
    
    print_color $BLUE "Installing CocoaPods..."
    
    if command_exists gem; then
        sudo gem install cocoapods
        if command_exists pod; then
            print_color $GREEN "✓ CocoaPods installed successfully!"
        else
            print_color $YELLOW "⚠️  CocoaPods installation may have failed"
        fi
    else
        print_color $YELLOW "⚠️  Ruby gems not available. Install CocoaPods manually if needed"
    fi
}

# Function to verify Flutter installation
verify_installation() {
    print_color $BLUE "Verifying Flutter installation..."
    
    local flutter_exe="$INSTALL_PATH/bin/flutter"
    
    if [[ -x "$flutter_exe" ]]; then
        print_color $GREEN "✓ Flutter executable found!"
        
        # Make sure Flutter is in PATH for this session
        export PATH="$PATH:$INSTALL_PATH/bin"
        
        print_color $BLUE "Running Flutter Doctor..."
        "$flutter_exe" doctor
        
        return 0
    else
        print_color $RED "✗ Flutter executable not found at $flutter_exe"
        return 1
    fi
}

# Function to show post-installation instructions
show_post_install_instructions() {
    print_color $GREEN "\n$(printf '=%.0s' {1..60})"
    print_color $GREEN "🎉 Flutter Installation Complete!"
    print_color $GREEN "$(printf '=%.0s' {1..60})"
    
    print_color $BLUE "\nNext Steps:"
    print_color $YELLOW "1. Restart your terminal or run 'source ~/.zshrc' (or ~/.bash_profile)"
    print_color $YELLOW "2. Run 'flutter doctor' to check for additional dependencies"
    print_color $YELLOW "3. Install Xcode from App Store for iOS development (if not done)"
    print_color $YELLOW "4. Install Android Studio for Android development"
    print_color $YELLOW "5. Install Visual Studio Code with Flutter extension"
    print_color $YELLOW "6. Run 'flutter create my_app' to create your first Flutter app"
    
    print_color $BLUE "\nUseful Commands:"
    print_color $YELLOW "• flutter doctor          - Check installation status"
    print_color $YELLOW "• flutter create <name>   - Create new Flutter project"
    print_color $YELLOW "• flutter run             - Run Flutter app"
    print_color $YELLOW "• flutter upgrade         - Update Flutter SDK"
    
    print_color $BLUE "\nmacOS Specific:"
    print_color $YELLOW "• For iOS development: Install Xcode from App Store"
    print_color $YELLOW "• For iOS simulator: Open Xcode and install iOS Simulator"
    print_color $YELLOW "• CocoaPods is required for iOS dependencies"
    
    print_color $BLUE "\nDocumentation: https://docs.flutter.dev"
}

# Main installation process
main() {
    print_color $GREEN "🚀 Flutter Automated Installer for macOS"
    print_color $GREEN "=========================================="
    
    # Check if running as root (not recommended)
    if [[ $EUID -eq 0 ]]; then
        print_color $YELLOW "⚠️  Running as root is not recommended for Flutter installation."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Step 1: Check macOS version
    check_macos_version
    
    # Step 2: Install Homebrew
    if ! install_homebrew; then
        print_color $RED "✗ Homebrew installation failed."
        exit 1
    fi
    
    # Step 3: Install system dependencies
    install_dependencies
    
    # Step 4: Check Xcode installation
    check_xcode
    
    # Step 5: Install Flutter SDK
    if ! install_flutter; then
        print_color $RED "✗ Flutter installation failed."
        exit 1
    fi
    
    # Step 6: Add Flutter to PATH
    if [[ "$ADD_TO_PATH" == true ]]; then
        add_to_path
    fi
    
    # Step 7: Configure iOS development
    configure_ios_development
    
    # Step 8: Install CocoaPods
    install_cocoapods
    
    # Step 9: Verify installation
    if ! verify_installation; then
        print_color $RED "✗ Flutter installation verification failed."
        exit 1
    fi
    
    # Step 10: Show post-install instructions
    show_post_install_instructions
    
    print_color $GREEN "\n✅ Installation completed successfully!"
    print_color $BLUE "Happy Flutter development! 🎯"
}

# Run main function
main "$@"