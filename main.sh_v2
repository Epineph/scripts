#!/bin/bash

# Ensure scripts directory is defined
SCRIPTS_DIR=~/scripts

# Source the individual scripts
source "$SCRIPTS_DIR/install_pkgs.sh"
source "$SCRIPTS_DIR/key_management.sh"
source "$SCRIPTS_DIR/git_management.sh"
source "$SCRIPTS_DIR/fzf_edit.sh"

# Function to check and install required packages
install_pkgs

# Function to generate SSH and GPG keys
manage_keys() {
    echo "Do you need to generate a GPG key? (y/n)"
    read -r NEED_GPG
    if [ "$NEED_GPG" = "y" ]; then
        generate_gpg_key
    fi

    echo "Do you need to generate an SSH key? (y/n)"
    read -r NEED_SSH
    if [ "$NEED_SSH" = "y" ]; then
        generate_ssh_key
    fi
}

# Function to manage Git operations
manage_git() {
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
}

# Function to edit files using fzf
edit_files() {
    fzf_edit
}

# Main menu
echo "Select an option:"
echo "1) Install required packages"
echo "2) Generate SSH and GPG keys"
echo "3) Manage Git operations"
echo "4) Edit files using fzf"
read -r OPTION

case $OPTION in
    1)
        install_pkgs
        ;;
    2)
        manage_keys
        ;;
    3)
        manage_git
        ;;
    4)
        edit_files
        ;;
    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac

