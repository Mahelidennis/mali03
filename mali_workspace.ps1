# Mali Workspace PowerShell Profile
# Add this to your PowerShell profile for automatic workspace setup

$env:MALI_WORKSPACE = "C:\Users\user\AndroidStudioProjects\mali03"
$env:FLUTTER_PATH = "C:\Users\user\flutter\bin\flutter.bat"

# Function to navigate to Mali workspace
function Set-MaliWorkspace {
    Set-Location $env:MALI_WORKSPACE
    Write-Host "✅ Navigated to Mali workspace: $env:MALI_WORKSPACE" -ForegroundColor Green
}

# Function to run Flutter commands from Mali workspace
function Mali-Flutter {
    param([string]$Command)
    Set-Location $env:MALI_WORKSPACE
    & $env:FLUTTER_PATH $Command
}

# Function to run Firebase commands from Mali workspace
function Mali-Firebase {
    param([string]$Command)
    Set-Location $env:MALI_WORKSPACE
    firebase $Command
}

# Function to build Mali app
function Build-Mali {
    Set-Location $env:MALI_WORKSPACE
    Write-Host "🔨 Building Mali app..." -ForegroundColor Yellow
    & $env:FLUTTER_PATH clean
    & $env:FLUTTER_PATH pub get
    & $env:FLUTTER_PATH build web --release
    robocopy build\web public /E /MIR
    Write-Host "✅ Build complete!" -ForegroundColor Green
}

# Function to deploy Mali app
function Deploy-Mali {
    Set-Location $env:MALI_WORKSPACE
    Write-Host "🚀 Deploying Mali app..." -ForegroundColor Yellow
    firebase deploy --only hosting
    Write-Host "✅ Deployment complete!" -ForegroundColor Green
}

# Function to build and deploy Mali app
function Build-Deploy-Mali {
    Build-Mali
    Deploy-Mali
}

# Function to run full deploy and backup
function Deploy-Mali {
    Set-Location $env:MALI_WORKSPACE
    Write-Host "🚀 Running full deploy and backup..." -ForegroundColor Yellow
    & ".\deploy_and_backup.bat"
}

# Function to run Mali app
function Run-Mali {
    Set-Location $env:MALI_WORKSPACE
    Write-Host "🏃 Running Mali app..." -ForegroundColor Yellow
    & $env:FLUTTER_PATH run -d chrome
}

# Function to setup Mali workspace
function Setup-Mali {
    Set-Location $env:MALI_WORKSPACE
    Write-Host "🛠️ Setting up Mali workspace..." -ForegroundColor Yellow
    & $env:FLUTTER_PATH clean
    & $env:FLUTTER_PATH pub get
    Write-Host "✅ Setup complete!" -ForegroundColor Green
}

# Display available commands
function Show-MaliCommands {
    Write-Host "Mali Workspace Commands:" -ForegroundColor Cyan
    Write-Host "  Set-MaliWorkspace    - Navigate to Mali workspace" -ForegroundColor White
    Write-Host "  Mali-Flutter         - Run Flutter commands from Mali workspace" -ForegroundColor White
    Write-Host "  Mali-Firebase        - Run Firebase commands from Mali workspace" -ForegroundColor White
    Write-Host "  Build-Mali           - Build the Mali app" -ForegroundColor White
    Write-Host "  Deploy-Mali          - Deploy to Firebase (with backup)" -ForegroundColor White
    Write-Host "  Build-Deploy-Mali    - Build and deploy in one command" -ForegroundColor White
    Write-Host "  Run-Mali             - Run the app in Chrome" -ForegroundColor White
    Write-Host "  Setup-Mali           - Clean and get dependencies" -ForegroundColor White
    Write-Host "  Show-MaliCommands    - Show this help" -ForegroundColor White
}

Write-Host "🎯 Mali Workspace loaded! Type 'Show-MaliCommands' for available commands." -ForegroundColor Green
