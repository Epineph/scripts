#!/bin/bash

function install_pkgs() {
    local needed_pkgs=("openssh" "git" "wget" "github-cli" "python-virtualenv" "python-virtualenvwrapper")
    local missing_pkgs=()
    for pkg in "${needed_pkgs[@]}"; do
        if ! pacman -Qi "$pkg" &> /dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done
    if [ ${#missing_pkgs[@]} -ne 0 ]; then
        echo "The following packages are not installed: ${missing_pkgs[*]}"
        read -p "Do you want to install them? (Y/n) " -n 1 -r
        echo    # Move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            for package in "${missing_pkgs[@]}"; do
                yes | sudo pacman -S "$package"
                if [ $? -ne 0 ]; then
                    echo "Failed to install $package. Aborting."
                    exit 1
                fi
            done
        else
            echo "The following packages are required to continue: ${missing_pkgs[*]}. Aborting."
            exit 1
        fi
    fi
}

install_pkgs

