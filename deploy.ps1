# PowerShell Deploy Function for Mali App
# Usage: deploy

function Deploy-Mali {
    param(
        [switch]$Test = $false
    )
    
    $MaliWorkspace = "C:\Users\user\AndroidStudioProjects\mali03"
    
    # Navigate to workspace
    Set-Location $MaliWorkspace
    
    if ($Test) {
        Write-Host "🧪 Test Mode: Would run deployment..." -ForegroundColor Yellow
        Write-Host "Command: .\deploy_and_backup.bat" -ForegroundColor Gray
        return
    }
    
    # Check if deploy_and_backup.bat exists
    if (-not (Test-Path "deploy_and_backup.bat")) {
        Write-Host "❌ ERROR: deploy_and_backup.bat not found in $MaliWorkspace" -ForegroundColor Red
        Write-Host "Please make sure you are in the correct Mali project directory." -ForegroundColor Red
        return
    }
    
    # Run the deploy and backup script
    Write-Host "🚀 Running Mali app deployment..." -ForegroundColor Green
    & ".\deploy_and_backup.bat"
}

# Create alias for easier use
Set-Alias -Name deploy -Value Deploy-Mali

Write-Host "✅ Deploy function loaded!" -ForegroundColor Green
Write-Host "Usage: deploy" -ForegroundColor Cyan
Write-Host "Test: deploy -Test" -ForegroundColor Cyan
