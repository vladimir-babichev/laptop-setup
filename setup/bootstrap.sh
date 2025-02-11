#!/usr/bin/env bash

set -o errexit
set -o nounset

REPO_URL="https://github.com/vladimir-babichev/laptop-setup.git"
REPO_PATH="$HOME/laptop-setup"

# Color definitions
declare -A COLORS=(
    [background]="#282c34"
    [foreground]="#dcdfe4"
    [red]="#e06c75"
    [green]="#98c379"
    [yellow]="#e5c07b"
    [blue]="#61afef"
    [purple]="#c678dd"
    [cyan]="#56b6c2"
)

function msg() {
    local type=$1
    local text=$2

    printf "%b[%s] %s%b\n" "\033[${COLORS[$type]}m" "$(date '+%H:%M:%S')" "$text" "\033[0m"
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
    ./setup.sh --all
}

main "$@"
