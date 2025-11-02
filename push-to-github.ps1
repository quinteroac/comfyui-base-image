# PowerShell script to push changes to GitHub

param(
    [Parameter(Mandatory=$false)]
    [string]$Message = "",
    
    [Parameter(Mandatory=$false)]
    [string]$Branch = ""
)

# Function to display colored output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

Write-ColorOutput "Green" "=== GitHub Push Script ==="
Write-Output ""

# Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "Red" "Error: Git is not installed or not in PATH"
    exit 1
}

# Get current branch if not specified
if ([string]::IsNullOrEmpty($Branch)) {
    $Branch = git rev-parse --abbrev-ref HEAD
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "Red" "Error: Not a git repository"
        exit 1
    }
}

Write-ColorOutput "Yellow" "Current branch: $Branch"
Write-Output ""

# Check if there are changes
$status = git status --porcelain
if ([string]::IsNullOrEmpty($status)) {
    Write-ColorOutput "Yellow" "No changes to commit"
    Write-Output ""
    
    $pushAnyway = Read-Host "Do you want to push anyway? (y/N)"
    if ($pushAnyway -ne "y" -and $pushAnyway -ne "Y") {
        Write-Output "Aborted"
        exit 0
    }
}

# Show status
Write-ColorOutput "Cyan" "Current status:"
git status --short
Write-Output ""

# Get commit message
if ([string]::IsNullOrEmpty($Message)) {
    $Message = Read-Host "Enter commit message"
    if ([string]::IsNullOrEmpty($Message)) {
        Write-ColorOutput "Red" "Error: Commit message cannot be empty"
        exit 1
    }
}

# Stage all changes
Write-ColorOutput "Yellow" "Staging all changes..."
git add .
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Red" "Error: Failed to stage changes"
    exit 1
}

# Commit changes
Write-ColorOutput "Yellow" "Committing changes..."
git commit -m $Message
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Red" "Error: Failed to commit changes"
    exit 1
}

Write-ColorOutput "Green" "✓ Changes committed successfully"
Write-Output ""

# Push to remote
Write-ColorOutput "Yellow" "Pushing to origin/$Branch..."
git push origin $Branch
if ($LASTEXITCODE -ne 0) {
    Write-ColorOutput "Yellow" "Attempting to set upstream branch..."
    git push --set-upstream origin $Branch
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "Red" "Error: Failed to push to remote"
        exit 1
    }
}

Write-ColorOutput "Green" "✓ Successfully pushed to GitHub!"
Write-Output ""

# Show latest commit
Write-ColorOutput "Cyan" "Latest commit:"
git log -1 --oneline

