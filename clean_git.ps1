Write-Host "Starting Git History Cleanup..."

# 1. Rewrite Git history to completely remove the folders from all past commits
git filter-branch --force --index-filter "git rm --cached --ignore-unmatch -r windows linux macos web" --prune-empty --tag-name-filter cat -- --all

# 2. Remove the backup refs created by filter-branch
if (Test-Path ".git\refs\original\") {
    Remove-Item -Recurse -Force ".git\refs\original\"
}

# 3. Force the garbage collector to permanently delete the unreachable objects
git reflog expire --expire=now --all
git gc --prune=now
git gc --aggressive --prune=now

# 4. Push the rewritten history to GitHub (force push required)
git push origin --force --all

Write-Host "Cleanup Complete!"
