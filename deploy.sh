#!/bin/bash

# deploy.sh — builds the site and pushes both the source and the built output
# to GitHub. The site is served directly from the gh-pages branch (the contents
# of the public/ directory), so both branches need to be kept in sync.
#
# Usage:
#   ./deploy.sh                  # uses default commit message
#   ./deploy.sh "my message"     # uses custom commit message

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the site into public/ using Hugo.
# Requires Hugo 0.128.0+ (install via: brew install hugo)
hugo

# Stage everything — source files and the freshly built public/ directory.
git add -A

# Commit with a timestamp by default, or use the first argument if provided.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push the source (layouts, content, config) to the master branch.
git push origin master

# Push only the public/ subdirectory to the gh-pages branch, which is what
# GitHub Pages serves as the live site. Uses git subtree split so gh-pages
# contains just the built HTML with no Hugo source files.
#
# Note: the commented line below is an alternative that sometimes errors out
# on repos with complex history — use the subtree split version instead.
#git subtree push --prefix=public https://kmgolden@github.com/kmgolden/ctc gh-pages
git push origin `git subtree split --prefix public master`:gh-pages --force
