#!/bin/bash

# Flutter Automated Installation Script for Linux
# This script automates the Flutter SDK installation process on Linux
# Run with: bash install-flutter-linux.sh

set -e  # Exit on any error

# Default configuration
INSTALL_PATH="$HOME/flutter"
CHANNEL="stable"
ADD_TO_PATH=true
SKIP_ANDROID_STUDIO=false
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
    echo "  --skip-android-studio   Skip Android Studio installation prompts"
    echo "  -v, --verbose           Verbose output"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 --path /opt/flutter --channel beta"
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
        --skip-android-studio)
            SKIP_ANDROID_STUDIO=true
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

# Function to detect Linux distribution
detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo $ID
    elif [[ -f /etc/redhat-release ]]; then
        echo "rhel"
    elif [[ -f /etc/debian_version ]]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Function to install dependencies
install_dependencies() {
    print_color $BLUE "Installing system dependencies..."
    
    local distro=$(detect_distro)
    
    case $distro in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
            ;;
        fedora)
            sudo dnf install -y curl git unzip xz zip mesa-libGLU
            ;;
        centos|rhel)
            sudo yum install -y curl git unzip xz zip mesa-libGLU
            ;;
        arch)
            sudo pacman -S --noconfirm curl git unzip xz zip mesa
            ;;
        opensuse*)
            sudo zypper install -y curl git unzip xz zip Mesa-libGLU1
            ;;
        *)
            print_color $YELLOW "⚠️  Unknown distribution. Please ensure you have: curl, git, unzip, xz-utils, zip"
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
            ;;
    esac
    
    print_color $GREEN "✓ Dependencies installed successfully!"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Git if not present
install_git() {
    if command_exists git; then
        print_color $GREEN "✓ Git is already installed: $(git --version)"
        return 0
    fi
    
    print_color $YELLOW "Git not found. Installing Git..."
    
    local distro=$(detect_distro)
    
    case $distro in
        ubuntu|debian)
            sudo apt-get update && sudo apt-get install -y git
            ;;
        fedora)
            sudo dnf install -y git
            ;;
        centos|rhel)
            sudo yum install -y git
            ;;
        arch)
            sudo pacman -S --noconfirm git
            ;;
        opensuse*)
            sudo zypper install -y git
            ;;
        *)
            print_color $RED "✗ Unable to install Git automatically. Please install Git manually."
            return 1
            ;;
    esac
    
    if command_exists git; then
        print_color $GREEN "✓ Git installed successfully!"
        return 0
    else
        print_color $RED "✗ Git installation failed"
        return 1
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
    
    # Download Flutter SDK
    local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/$CHANNEL/linux/flutter_linux_3.16.0-$CHANNEL.tar.xz"
    local flutter_archive="/tmp/flutter_linux.tar.xz"
    
    print_color $BLUE "Downloading Flutter SDK..."
    if curl -L "$flutter_url" -o "$flutter_archive"; then
        print_color $GREEN "✓ Flutter SDK downloaded successfully!"
    else
        print_color $RED "✗ Failed to download Flutter SDK"
        return 1
    fi
    
    # Extract Flutter SDK
    print_color $BLUE "Extracting Flutter SDK..."
    if tar -xf "$flutter_archive" -C "$(dirname "$INSTALL_PATH")"; then
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
    if [[ -n "$ZSH_VERSION" ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ -n "$BASH_VERSION" ]]; then
        shell_rc="$HOME/.bashrc"
    else
        shell_rc="$HOME/.profile"
    fi
    
    # Check if Flutter is already in PATH
    if echo "$PATH" | grep -q "$flutter_bin"; then
        print_color $GREEN "✓ Flutter is already in PATH"
        return 0
    fi
    
    print_color $BLUE "Adding Flutter to PATH in $shell_rc..."
    
    # Add Flutter to PATH
    echo "" >> "$shell_rc"
    echo "# Flutter SDK" >> "$shell_rc"
    echo "export PATH=\"\$PATH:$flutter_bin\"" >> "$shell_rc"
    
    # Update current session PATH
    export PATH="$PATH:$flutter_bin"
    
    print_color $GREEN "✓ Flutter added to PATH successfully!"
    print_color $YELLOW "Note: Restart your terminal or run 'source $shell_rc' to apply changes"
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
    print_color $YELLOW "1. Restart your terminal or run 'source ~/.bashrc' (or ~/.zshrc)"
    print_color $YELLOW "2. Run 'flutter doctor' to check for additional dependencies"
    print_color $YELLOW "3. Install Android Studio for Android development"
    print_color $YELLOW "4. Install Visual Studio Code with Flutter extension"
    print_color $YELLOW "5. Run 'flutter create my_app' to create your first Flutter app"
    
    print_color $BLUE "\nUseful Commands:"
    print_color $YELLOW "• flutter doctor          - Check installation status"
    print_color $YELLOW "• flutter create <name>   - Create new Flutter project"
    print_color $YELLOW "• flutter run             - Run Flutter app"
    print_color $YELLOW "• flutter upgrade         - Update Flutter SDK"
    
    print_color $BLUE "\nDocumentation: https://docs.flutter.dev"
}

# Main installation process
main() {
    print_color $GREEN "🚀 Flutter Automated Installer for Linux"
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
    
    # Step 1: Install system dependencies
    install_dependencies
    
    # Step 2: Install Git (required for Flutter)
    if ! install_git; then
        print_color $RED "✗ Git installation failed. Flutter requires Git to function properly."
        exit 1
    fi
    
    # Step 3: Install Flutter SDK
    if ! install_flutter; then
        print_color $RED "✗ Flutter installation failed."
        exit 1
    fi
    
    # Step 4: Add Flutter to PATH
    if [[ "$ADD_TO_PATH" == true ]]; then
        add_to_path
    fi
    
    # Step 5: Verify installation
    if ! verify_installation; then
        print_color $RED "✗ Flutter installation verification failed."
        exit 1
    fi
    
    # Step 6: Show post-install instructions
    show_post_install_instructions
    
    print_color $GREEN "\n✅ Installation completed successfully!"
    print_color $BLUE "Happy Flutter development! 🎯"
}

# Run main function
main "$@"