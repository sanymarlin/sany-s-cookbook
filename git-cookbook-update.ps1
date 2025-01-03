# Check for changes in the repository
$changes = git status --porcelain
if ($changes) {
    Write-Output "Changes detected. Staging files..."
    
    # Stage all changes
    git add .

    # Commit the changes with a default or custom message
    Write-Output "Enter commit message: "
    $commit_message = Read-Host
    if (-not $commit_message) {
        $commit_message = "Update changes"
    }
    git commit -m $commit_message

    # Push the changes to the remote repository
    Write-Output "Pushing changes to remote repository..."
    git push origin main

    Write-Output "Changes have been pushed successfully!"
} else {
    Write-Output "No changes to commit. Repository is up to date."
}
