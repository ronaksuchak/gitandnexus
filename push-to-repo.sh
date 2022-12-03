#!/bin/bash

# Check if the user provided the required arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 [pull|push] [repository-url]"
  exit 1
fi

# Store the arguments in variables
action=$1
repo_url=$2

# Generate a unique folder name based on the current date and time
folder_name=$(date +"%Y-%m-%d-%H-%M-%S")

# Check if the nexus command is available
if ! which nexus >/dev/null; then
  # Install the nexus-cli package with npm
  npm install -g nexus-cli
fi

# Check the action and perform the appropriate Git and Nexus commands
if [ $action == "pull" ]; then
  # Pull the latest changes from the repository
  git pull $repo_url

  # Find all files larger than 500MB in the repository
  large_files=$(find . -type f -size +500M)

  # Loop through the large files and download them from Nexus
  for file in $large_files; do
    nexus download $file --url https://nexus.example.com --repository my-repository --folder $folder_name
  done
elif [ $action == "push" ]; then
  # Stage all changes in the repository
  git add .

  # Commit the changes with a commit message
  git commit -m "Committing changes"

  # Push the changes to the repository
  git push $repo_url

  # Find all files larger than 500MB in the repository
  large_files=$(find . -type f -size +500M)

  # Loop through the large files and upload them to Nexus
  for file in $large_files; do
    nexus upload $file --url https://nexus.example.com --repository my-repository --folder $folder_name
  done
else
  # Print an error message if the action is not recognized
  echo "Error: Invalid action. Valid actions are 'pull' and 'push'"
  exit 1
fi
