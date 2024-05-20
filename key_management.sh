#!/bin/bash

function generate_gpg_key() {
    echo "Generating a new GPG key..."
    gpg --full-generate-key
    echo "Listing your GPG keys..."
    gpg --list-secret-keys --keyid-format=long
    echo "Enter the GPG key ID (long form) you'd like to use for signing commits:"
    read -r GPG_KEY_ID
    echo "Configuring Git to use the GPG key..."
    git config --global user.signingkey "$GPG_KEY_ID"
    echo "Would you like to sign all commits by default? (y/n)"
    read -r SIGN_ALL_COMMITS
    if [ "$SIGN_ALL_COMMITS" = "y" ]; then
        git config --global commit.gpgsign true
    fi
    add_line_to_file "export GPG_TTY=$(tty)" "$HOME/.bashrc"
    add_line_to_file "export GPG_TTY=$(tty)" "$HOME/.zshrc"
    echo "GPG key generated and Git configured to use it for signing commits."
    echo "Your GPG public key to add to GitHub:"
    gpg --armor --export "$GPG_KEY_ID"
}

function generate_ssh_key() {
    local SSH_KEY="$HOME/.ssh/id_rsa"
    echo "Generating a new SSH key..."
    ssh-keygen -t rsa -b 4096 -C "$(git config user.email)"
    echo "Starting the ssh-agent..."
    eval "$(ssh-agent -s)"
    echo "Adding your SSH key to the ssh-agent..."
    ssh-add "$SSH_KEY"
    echo "Your SSH public key to add to GitHub:"
    cat "$SSH_KEY.pub"
}

function add_line_to_file() {
    local LINE_TO_ADD="$1"
    local FILE_TO_EDIT="$2"
    if ! grep -qF "$LINE_TO_ADD" "$FILE_TO_EDIT"; then
        echo "$LINE_TO_ADD" | sudo tee -a "$FILE_TO_EDIT"
    fi
}

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

