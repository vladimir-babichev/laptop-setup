#!/usr/bin/env bash

: "${ROOT_DIR:="$(git rev-parse --show-toplevel)"}"
: "${SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"}"

ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
MOZILLA_ADDONS_API="https://addons.mozilla.org/api/v5"
VSCODE_DIR="$HOME/Library/Application Support/Code/User"

DO_FIREFOX=""
DO_HELM=""
DO_ITERM=""
DO_KREW=""
DO_MAS=""
DO_MACOS=""
DO_PACKAGES=""
DO_VSCODE=""
DO_ZSH=""

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
    gum style --foreground "${COLORS[$type]}" "[$(date '+%H:%M:%S')] $text"
}

function usage() {
    local SCRIPT="${0##*/}"
    local EXIT_CODE="${1:-0}"

    echo "Usage: $SCRIPT [options]"
    echo ""
    echo "This script bootstraps a Dev laptop."
    echo "Options:"
    echo "  -a, --all           Install everything"
    echo "  -f, --firefox       Install Firefox extensions"
    echo "  -i, --iterm         Configure iTerm2"
    echo "  -k, --krew          Install Krew plugins"
    echo "  -m, --helm          Install Helm plugins"
    echo "  -o, --macos         Configure macOS settings"
    echo "  -p, --packages      Install default packages with Homebrew"
    echo "  -s, --mas           Install Mac App Store applications"
    echo "  -v, --vscode        Install VSCode extensions, keybindings, settings"
    echo "  -z, --zsh           Install Zinit, link dotfiles, configure ZSH"
    echo "  -h, --help          Show this message and exit"
    echo ""
    echo "Examples:"
    echo "  ./$SCRIPT --packages --zsh --helm"
    echo ""

    exit "$EXIT_CODE"
}

function fix_permissions() {
    msg "blue" "Fixing /usr/local/bin permissions..."

    sudo chmod +a "user:${USER} allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" /usr/local/bin

    msg "green" "Permissions set"
}

function install_system_packages() {
    fix_permissions

    msg "blue" "Installing Brew Packages..."

    brew bundle --file "$ROOT_DIR/brew/Brewfile-system"

    msg "green" "Packages installed"
}

function configure_zsh() {
    msg "blue" "Configuring ZSH..."

    # Install Zinit
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    zsh -i -c 'zinit self-update'

    # Link configuration files
    find "$ROOT_DIR/dotfiles" -type f -depth 1 -exec ln -sf "{}" "$HOME/" \;
    find "$ROOT_DIR/dotfiles" -type d -depth 1 -exec sh -c 'mkdir -p "$HOME/${1#*dotfiles/}"' _ {} \;
    find "$ROOT_DIR/dotfiles" -depth 2 -exec sh -c 'ln -sf "{}" "$HOME/${1#*dotfiles/}"' _ {} \;

    msg "green" "ZSH configured. Please restart your shell"
}

function configure_macos() {
    msg "blue" "Configuring macOS..."

    $SCRIPT_DIR/macos.sh

    msg "green" "macOS configured"
}

function install_helm_plugins() {
    msg "blue" "Installing Helm plugins..."

    while read -r plugin; do
        msg "cyan" "  Installing: $plugin"
        helm plugin install "$plugin"
    done <<<"$(yq -r '.plugins[]' "$ROOT_DIR/helm/plugins.yaml")"

    msg "green" "Helm plugins installed"
}

function install_krew_plugins() {
    msg "blue" "Installing Krew plugins..."

    while read -r plugin; do
        msg "cyan" "  Installing: $plugin"
        kubectl krew install "$plugin"
    done <<< "$(yq -r '.plugins[] | .name' "$ROOT_DIR/krew/plugins.yaml")"

    msg "green" "Krew plugins installed"
}

function configure_vscode() {
    msg "blue" "Configuring VSCode..."

    msg "cyan" "  Installing extensions..."
    brew bundle --file "$ROOT_DIR/brew/Brewfile-vscode"

    msg "cyan" "  Configuring..."
    for file in "$ROOT_DIR/vscode"/*; do
        filename=$(basename "$file")
        if [[ -f "$VSCODE_DIR/$filename" ]]; then
            cp -f "$VSCODE_DIR/$filename" "$VSCODE_DIR/$filename.backup"
        fi
        ln -sf "$file" "$VSCODE_DIR/"
    done

    msg "green" "VSCode configured"
}

function discover_firefox_extensions() {
    local extension_name="$1"
    local guid="$2"

    # Query AMO API
    local search_result
    search_result=$(curl -s "${MOZILLA_ADDONS_API}/addons/search/?guid=${guid}&app=firefox&type=extension&sort=relevance")

    # Parse and cache result
    echo "$search_result" | jq -r '.results[] |
        select(.slug == "'"$extension_name"'") |
        .current_version.file.url'
}

function install_firefox_extension() {
    local name="$1"
    local guid="$2"
    local url=$(discover_firefox_extensions "$name" "$guid")

    if [[ -n "$url" ]]; then
        TEMP_XPI=$(mktemp).xpi

        gum spin --spinner dot --title "Downloading $name..." -- \
            curl -L "$url" -o "$TEMP_XPI"
        open -a Firefox "$TEMP_XPI"

        gum confirm "Did you complete $name installation in Firefox?"

        rm -f "$TEMP_XPI"
    else
        msg "red" "Extension '$name' not found"
    fi
}

function install_firefox_extensions() {
    msg "blue" "Installing Firefox extensions..."

    extensions=($(yq -r '.extensions[] | [.slug, .guid] | @tsv' "$ROOT_DIR/firefox/extensions.yaml"))
    for ((i=0; i<${#extensions[@]}; i+=2)); do
        slug="${extensions[i]}"
        guid="${extensions[i+1]}"
        msg "cyan" "  Installing: $slug"
        install_firefox_extension "$slug" "$guid"
    done

    msg "green" "Firefox configured"
}

function configure_iterm() {
    msg "blue" "Configuring iTerm2..."

    if [[ -f "$ITERM_PLIST" ]]; then
        cp -f "$ITERM_PLIST" "${ITERM_PLIST}.backup"
    fi

    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$ROOT_DIR/iTerm2"
    defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -integer 2
    defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true

    msg "green" "iTerm2 configured. Please restart iTerm2"
}

function install_mas_apps() {
    msg "blue" "Installing Mac App Store applications..."

    brew bundle --file "$ROOT_DIR/brew/Brewfile-mas"

    msg "green" "Mac App Store applications installed"
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--all)       DO_ALL="1";;
            -f|--firefox)   DO_FIREFOX="1" ;;
            -i|--iterm)     DO_ITERM="1" ;;
            -k|--krew)      DO_KREW="1" ;;
            -m|--helm)      DO_HELM="1" ;;
            -o|--macos)     DO_MACOS="1" ;;
            -p|--packages)  DO_PACKAGES="1" ;;
            -s|--mas)       DO_MAS="1" ;;
            -v|--vscode)    DO_VSCODE="1" ;;
            -z|--zsh)       DO_ZSH="1" ;;
            -h|--help)      usage 0 ;;
            *)              usage 1 ;;
        esac
        shift
    done
}


function prompt_user() {
    mapfile -t SELECTED < <(
        gum choose --no-limit --selected=* --header "Select setup items:" \
            "Configure iTerm2" \
            "Configure macOS" \
            "Configure VSCode" \
            "Configure ZSH" \
            "Install Firefox Extensions" \
            "Install Helm Plugins" \
            "Install Krew Plugins" \
            "Install AppStore Packages" \
            "Install System Packages"
    )

    for item in "${SELECTED[@]}"; do
        case "$item" in
            **AppStore**) DO_MAS="1" ;;
            **Firefox**)  DO_FIREFOX="1" ;;
            **Helm**)     DO_HELM="1" ;;
            **iTerm2**)   DO_ITERM="1" ;;
            **Krew**)     DO_KREW="1" ;;
            **macOS**)    DO_MACOS="1" ;;
            **System**)   DO_PACKAGES="1" ;;
            **VSCode**)   DO_VSCODE="1" ;;
            **ZSH**)      DO_ZSH="1" ;;
        esac
    done
}


function main() {
    if [[ $# -gt 0 ]]; then
        parse_arguments "$@"
    else
        prompt_user
    fi

    [[ -n "$DO_PACKAGES" || -n "$DO_ALL" ]] && install_system_packages
    [[ -n "$DO_ZSH"      || -n "$DO_ALL" ]] && configure_zsh
    [[ -n "$DO_KREW"     || -n "$DO_ALL" ]] && install_krew_plugins
    [[ -n "$DO_HELM"     || -n "$DO_ALL" ]] && install_helm_plugins
    [[ -n "$DO_VSCODE"   || -n "$DO_ALL" ]] && configure_vscode
    [[ -n "$DO_FIREFOX"  || -n "$DO_ALL" ]] && install_firefox_extensions
    [[ -n "$DO_ITERM"    || -n "$DO_ALL" ]] && configure_iterm
    [[ -n "$DO_MAS"      || -n "$DO_ALL" ]] && install_mas_apps
    [[ -n "$DO_MACOS"    || -n "$DO_ALL" ]] && configure_macos
}

main "$@"
