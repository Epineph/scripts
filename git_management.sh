#!/bin/bash

function git_push() {
    local commit_message
    local repo_url
    local sanitized_url

    if [ -z "$GITHUB_TOKEN" ]; then
        echo "Error: GITHUB_TOKEN is not set in your environment."
        return 1
    fi

    echo "Enter the commit message:"
    read -r commit_message

    # Add all changes to the repository
    git add .

    # Commit the changes with the provided message
    git commit -S -m "$commit_message"

    # Get the repository URL and sanitize it
    repo_url=$(git config --get remote.origin.url)
    sanitized_url=$(echo "$repo_url" | sed 's|https://|https://'"$GITHUB_TOKEN"'@|')

    # Push the changes using the personal access token for authentication
    git push "$sanitized_url" main

    echo "Changes committed and pushed successfully."
}

function git_pull_all() {
    # Store the current directory
    local current_dir=$(pwd)

    # Iterate over each directory in the current directory
    for dir in */; do
        # Check if the directory is a git repository
        if [ -d "${dir}/.git" ]; then
            echo "Updating ${dir}..."
            cd "${dir}" || return # Change to the directory or exit on failure
            
            # Optionally, checkout a specific branch. Remove or modify as needed.
            git checkout && git pull
            git config --global --add safe.directory "${dir}"
            # Pull the latest changes
            #git pull

            # Return to the original directory
            cd "${current_dir}" || return
        else
            echo "${dir} is not a git repository."
        fi
    done
}

function initialize_repo() {
    # Function to get the current directory name
    get_current_directory_name() {
        basename "$PWD"
    }

    # Prompt user for repository name
    echo "Would you like to use the current directory name as the repository name? (y/n)"
    read -r use_current_dir_name

    if [ "$use_current_dir_name" = "y" ]; then
        REPO_NAME=$(get_current_directory_name)
    else
        echo "Please enter the repository name:"
        read -r REPO_NAME
    fi

    # Initialize a new Git repository
    git init

    # Add all files to the repository
    git add .

    # Commit the files
    git commit -m "Initial commit"

    # Create a new repository on GitHub
    gh repo create "$REPO_NAME" --public --source=. --remote=origin

    # Push the files to the new GitHub repository
    git push -u origin master

    echo "Repository '$REPO_NAME' created and files uploaded successfully."
}

# Main script logic
echo "Do you need to initialize a new repository? (y/n)"
read -r NEED_INIT
if [ "$NEED_INIT" = "y" ]; then
    initialize_repo
fi

echo "Do you need to pull all repositories in the current directory? (y/n)"
read -r NEED_PULL
if [ "$NEED_PULL" = "y" ]; then
    git_pull_all
fi

echo "Do you need to push changes to the repository? (y/n)"
read -r NEED_PUSH
if [ "$NEED_PUSH" = "y" ]; then
    git_push
fi

