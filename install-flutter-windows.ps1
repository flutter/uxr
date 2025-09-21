# Flutter Automated Installation Script for Windows
# This script automates the Flutter SDK installation process on Windows
# Run with: powershell -ExecutionPolicy Bypass -File install-flutter-windows.ps1

param(
    [string]$InstallPath = "$env:USERPROFILE\flutter",
    [string]$Channel = "stable",
    [switch]$AddToPath = $true,
    [switch]$SkipAndroidStudio = $false,
    [switch]$Verbose = $false
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Cyan"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Add-ToPath {
    param([string]$PathToAdd)
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($currentPath -notlike "*$PathToAdd*") {
        Write-ColorOutput "Adding Flutter to PATH..." $Blue
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$PathToAdd", "User")
        $env:Path += ";$PathToAdd"
        Write-ColorOutput "✓ Flutter added to PATH successfully!" $Green
    } else {
        Write-ColorOutput "✓ Flutter is already in PATH" $Green
    }
}

function Install-Git {
    Write-ColorOutput "Checking for Git installation..." $Blue
    
    try {
        $gitVersion = git --version 2>$null
        if ($gitVersion) {
            Write-ColorOutput "✓ Git is already installed: $gitVersion" $Green
            return $true
        }
    } catch {
        Write-ColorOutput "Git not found. Installing Git..." $Yellow
        
        # Download and install Git
        $gitUrl = "https://github.com/git-for-windows/git/releases/latest/download/Git-2.42.0.2-64-bit.exe"
        $gitInstaller = "$env:TEMP\GitInstaller.exe"
        
        try {
            Write-ColorOutput "Downloading Git installer..." $Blue
            Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller -UseBasicParsing
            
            Write-ColorOutput "Installing Git (this may take a few minutes)..." $Blue
            Start-Process -FilePath $gitInstaller -ArgumentList "/SILENT" -Wait
            
            # Refresh environment variables
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            
            Remove-Item $gitInstaller -Force
            Write-ColorOutput "✓ Git installed successfully!" $Green
            return $true
        } catch {
            Write-ColorOutput "✗ Failed to install Git: $($_.Exception.Message)" $Red
            return $false
        }
    }
}

function Install-Flutter {
    param([string]$InstallPath, [string]$Channel)
    
    Write-ColorOutput "Starting Flutter installation..." $Blue
    Write-ColorOutput "Installation path: $InstallPath" $Blue
    Write-ColorOutput "Channel: $Channel" $Blue
    
    # Create installation directory
    if (!(Test-Path $InstallPath)) {
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # Download Flutter SDK
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/$Channel/windows/flutter_windows_3.16.0-$Channel.zip"
    $flutterZip = "$env:TEMP\flutter_windows.zip"
    
    try {
        Write-ColorOutput "Downloading Flutter SDK..." $Blue
        Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip -UseBasicParsing
        
        Write-ColorOutput "Extracting Flutter SDK..." $Blue
        Expand-Archive -Path $flutterZip -DestinationPath (Split-Path $InstallPath) -Force
        
        Remove-Item $flutterZip -Force
        Write-ColorOutput "✓ Flutter SDK extracted successfully!" $Green
        
        return $true
    } catch {
        Write-ColorOutput "✗ Failed to download/extract Flutter: $($_.Exception.Message)" $Red
        return $false
    }
}

function Test-FlutterInstallation {
    param([string]$FlutterPath)
    
    Write-ColorOutput "Verifying Flutter installation..." $Blue
    
    try {
        $flutterExe = Join-Path $FlutterPath "bin\flutter.bat"
        if (Test-Path $flutterExe) {
            Write-ColorOutput "✓ Flutter executable found!" $Green
            
            # Run flutter doctor
            Write-ColorOutput "Running Flutter Doctor..." $Blue
            & $flutterExe doctor
            
            return $true
        } else {
            Write-ColorOutput "✗ Flutter executable not found at $flutterExe" $Red
            return $false
        }
    } catch {
        Write-ColorOutput "✗ Error verifying Flutter installation: $($_.Exception.Message)" $Red
        return $false
    }
}

function Show-PostInstallInstructions {
    Write-ColorOutput "`n" + "="*60 $Green
    Write-ColorOutput "🎉 Flutter Installation Complete!" $Green
    Write-ColorOutput "="*60 $Green
    
    Write-ColorOutput "`nNext Steps:" $Blue
    Write-ColorOutput "1. Restart your terminal/PowerShell to refresh PATH" $Yellow
    Write-ColorOutput "2. Run 'flutter doctor' to check for additional dependencies" $Yellow
    Write-ColorOutput "3. Install Android Studio for Android development (if not skipped)" $Yellow
    Write-ColorOutput "4. Install Visual Studio Code with Flutter extension" $Yellow
    Write-ColorOutput "5. Run 'flutter create my_app' to create your first Flutter app" $Yellow
    
    Write-ColorOutput "`nUseful Commands:" $Blue
    Write-ColorOutput "• flutter doctor          - Check installation status" $Yellow
    Write-ColorOutput "• flutter create <name>   - Create new Flutter project" $Yellow
    Write-ColorOutput "• flutter run             - Run Flutter app" $Yellow
    Write-ColorOutput "• flutter upgrade         - Update Flutter SDK" $Yellow
    
    Write-ColorOutput "`nDocumentation: https://docs.flutter.dev" $Blue
}

# Main installation process
Write-ColorOutput "🚀 Flutter Automated Installer for Windows" $Green
Write-ColorOutput "===========================================" $Green

# Check if running as administrator (optional but recommended)
if (!(Test-Administrator)) {
    Write-ColorOutput "⚠️  Not running as administrator. Some features may be limited." $Yellow
}

# Step 1: Install Git (required for Flutter)
if (!(Install-Git)) {
    Write-ColorOutput "✗ Git installation failed. Flutter requires Git to function properly." $Red
    exit 1
}

# Step 2: Install Flutter SDK
if (!(Install-Flutter -InstallPath $InstallPath -Channel $Channel)) {
    Write-ColorOutput "✗ Flutter installation failed." $Red
    exit 1
}

# Step 3: Add Flutter to PATH
if ($AddToPath) {
    Add-ToPath -PathToAdd "$InstallPath\bin"
}

# Step 4: Verify installation
if (!(Test-FlutterInstallation -FlutterPath $InstallPath)) {
    Write-ColorOutput "✗ Flutter installation verification failed." $Red
    exit 1
}

# Step 5: Show post-install instructions
Show-PostInstallInstructions

Write-ColorOutput "`n✅ Installation completed successfully!" $Green
Write-ColorOutput "Happy Flutter development! 🎯" $Blue