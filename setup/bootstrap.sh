#!/usr/bin/env bash

set -o errexit
set -o nounset

REPO_URL="https://github.com/vladimir-babichev/laptop-setup.git"
REPO_PATH="$HOME/laptop-setup"

# Color definitions
COLOR_BACKGROUND="#282c34"
COLOR_FOREGROUND="#dcdfe4"
COLOR_RED="#e06c75"
COLOR_GREEN="#98c379"
COLOR_YELLOW="#e5c07b"
COLOR_BLUE="#61afef"
COLOR_PURPLE="#c678dd"
COLOR_CYAN="#56b6c2"

function msg() {
    local type=$1
    local text=$2
    local color

    # Simple case statement to replace associative array lookup
    case "$type" in
        "background") color="$COLOR_BACKGROUND" ;;
        "foreground") color="$COLOR_FOREGROUND" ;;
        "red") color="$COLOR_RED" ;;
        "green") color="$COLOR_GREEN" ;;
        "yellow") color="$COLOR_YELLOW" ;;
        "blue") color="$COLOR_BLUE" ;;
        "purple") color="$COLOR_PURPLE" ;;
        "cyan") color="$COLOR_CYAN" ;;
        *) color="$COLOR_FOREGROUND" ;;
    esac

    printf "%b[%s] %s%b\n" "\033[${color}m" "$(date '+%H:%M:%S')" "$text" "\033[0m"
}

function install_xcode() {
    if ! xcode-select -p &>/dev/null; then
        msg "blue" "Installing xCode Command Line Tools..."

        xcode-select --install
    fi

	msg "green" "xCode Command Line Tools installed"
}

function install_homebrew() {
    if ! command -v brew &>/dev/null; then
        msg "blue" "Installing Homebrew..."

        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

	brew install git gum

	msg "green" "Homebrew installed"
}

function clone_repo() {
    if [[ ! -d "$REPO_PATH" ]]; then
        msg "blue" "Cloning laptop-setup repository..."

        mkdir -p "$REPO_PATH"
        git clone "$REPO_URL" "$REPO_PATH"
    fi

	msg "green" "Repository cloned"
}

function main() {
    msg "blue" "Starting laptop bootstrap..."

    install_xcode
    install_homebrew
    clone_repo

    msg "blue" "Running setup script..."

    cd "$REPO_PATH/setup"
    ./laptop-setup
}

main "$@"
