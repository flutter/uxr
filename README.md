# Flutter User Experience Research (UXR)

This repo provides a space for Flutter's UXR team to collaborate with Flutter contributors and academic researchers. All communications in this repo are expected to follow [Flutter's code of conduct](https://github.com/flutter/flutter/blob/master/CODE_OF_CONDUCT.md).

How to use this repo:
* [Issues](https://github.com/flutter/uxr/issues) are for tracking tasks in an active research study we conduct in public. Resolutions of issues usually are achieved by changes made to files in the repo (including those in the docs directory). Anyone can post in this section.
* [Discussions](https://github.com/flutter/uxr/discussions) are for having open-ended conversations about a research topic. There is no expectation that those conversations must reach a resolution nor closure. Anyone can post in this section.
* [Documentation](./docs/README.md) is used to host public research documents that we do not expect frequent changes or do not expect community contributions.

## 🚀 Flutter Automated Installation Scripts

We've created automated installation scripts to make Flutter setup a one-step process across all platforms. These scripts handle system dependencies, SDK installation, PATH configuration, and verification automatically.

### Quick Start

#### Universal Installer (Linux/macOS)
```bash
# Download and run the universal installer
curl -fsSL https://raw.githubusercontent.com/flutter/uxr/master/install-flutter.sh | bash
```

#### Platform-Specific Installers

**Windows (PowerShell)**
```powershell
# Download and run
powershell -ExecutionPolicy Bypass -Command "& {Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/flutter/uxr/master/install-flutter-windows.ps1' -OutFile 'install-flutter-windows.ps1'; .\install-flutter-windows.ps1}"
```

**Linux**
```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/flutter/uxr/master/install-flutter-linux.sh | bash
```

**macOS**
```bash
# Download and run
curl -fsSL https://raw.githubusercontent.com/flutter/uxr/master/install-flutter-macos.sh | bash
```

### What These Scripts Do

1. **System Dependencies**: Installs required tools (Git, curl, unzip, etc.)
2. **Flutter SDK**: Downloads and extracts the latest Flutter SDK
3. **PATH Configuration**: Automatically adds Flutter to your system PATH
4. **Platform Setup**: Configures platform-specific requirements (Xcode, CocoaPods, etc.)
5. **Verification**: Runs `flutter doctor` to verify installation
6. **Post-Install Guidance**: Provides next steps and useful commands

### Configuration Options

All scripts support customization options:
```bash
-p, --path PATH          # Custom installation path (default: $HOME/flutter)
-c, --channel CHANNEL    # Flutter channel: stable, beta, dev (default: stable)
--no-path               # Don't add Flutter to PATH
-v, --verbose           # Enable verbose output
-h, --help              # Show help message
```

### Available Scripts

- [`install-flutter-windows.ps1`](install-flutter-windows.ps1) - PowerShell script for Windows
- [`install-flutter-linux.sh`](install-flutter-linux.sh) - Bash script for Linux
- [`install-flutter-macos.sh`](install-flutter-macos.sh) - Bash script for macOS  
- [`install-flutter.sh`](install-flutter.sh) - Universal launcher script

For detailed documentation, troubleshooting, and advanced usage, see the individual script files.

## Survey Metadata
When a PR is merged to update survey metadata located in `surveys`, you can verify that the directory has been successfully pushed to Google Cloud Storage by:
- Clicking the green checkmark for the latest commit on the [repo homepage](https://github.com/flutter/uxr) or
- Visiting [go/flutter-uxr-gcs-build](go/flutter-uxr-gcs-build) to see full upload history. Please contact @KhanhNwin if you need access. 

![GitHub green checkmark on commit](https://user-images.githubusercontent.com/102626803/278446271-cb4ccdbf-5831-4ffc-bc99-6951b5c691ce.png)