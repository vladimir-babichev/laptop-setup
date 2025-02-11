#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
MOZILLA_ADDONS_API="https://addons.mozilla.org/api/v5"
VSCODE_DIR="$HOME/Library/Application Support/Code/User"


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
    echo "  -p, --packages      Install default packages with Homebrew"
    echo "  -v, --vscode        Install VSCode extensions, keybindings, settings"
    echo "  -z, --zsh           Install Zinit, link dotfiles, configure ZSH"
    echo "  -h, --help          Show this message and exit"
    echo ""
    echo "Examples:"
    echo "  $SCRIPT --packages --zsh --helm"
    echo ""
    exit "$EXIT_CODE"
}

function fix_permissions() {
    sudo chmod +a "user:${USER} allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" /usr/local/bin
}

function install_system_packages() {
    fix_permissions

    brew bundle --file brew/Brewfile-system
}

function configure_zsh() {
    # Install Zinit
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
    zsh -i -c 'zinit self-update'

    # Link configuration files
    find "$SCRIPT_DIR/dotfiles" -type f -depth 1 -exec ln -sf "$PWD/{}" "$HOME/" \;
    find "$SCRIPT_DIR/dotfiles" -type d -depth 1 -exec sh -c 'mkdir -p "$HOME/${1#dotfiles/}"' _ {} \;
    find "$SCRIPT_DIR/dotfiles" -depth 2 -exec sh -c 'ln -sf "$PWD/{}" "$HOME/${1#dotfiles/}"' _ {} \;
}

function install_helm_plugins() {
    msg "blue" "Installing Helm plugins..."

    while read -r plugin; do
        msg "cyan" "Installing: $plugin"
        helm plugin install "$plugin"
    done <<<"$(yq -r '.plugins[]' "helm/plugins.yaml")"
}

function install_krew_plugins() {
    msg "blue" "Installing Krew plugins..."

    while read -r plugin; do
        msg "cyan" "Installing: $plugin"
        kubectl krew install "$plugin"
    done <<< "$(yq -r '.plugins[] | .name' "krew/plugins.yaml")"
}

function configure_vscode() {
    brew bundle --file brew/Brewfile-vscode

    for file in "$SCRIPT_DIR/vscode"/*; do
        filename=$(basename "$file")
        if [[ -f "$VSCODE_DIR/$filename" ]]; then
            cp -f "$VSCODE_DIR/$filename" "$VSCODE_DIR/$filename.backup"
        fi
        ln -sf "$file" "$VSCODE_DIR/"
    done
}

discover_firefox_extensions() {
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

install_firefox_extension() {
    local name="$1"
    local guid="$2"
    local url=$(discover_firefox_extensions "$name" "$guid")

    if [[ -n "$url" ]]; then
        TEMP_XPI=$(mktemp).xpi
        gum spin --spinner dot --title "Downloading $name..." -- \
            curl -L "$url" -o "$TEMP_XPI"
        open -a Firefox "$TEMP_XPI"
        gum confirm "Did you complete the installation of $name in Firefox?"
        rm -f "$TEMP_XPI"
    else
        msg "red" "Extension '$name' not found"
    fi
}

install_firefox_extensions() {
    msg "blue" "Installing Firefox extensions..."
    [[ -f "$SCRIPT_DIR/firefox/extensions.yaml" ]] || return 1

    extensions=($(yq -r '.extensions[] | [.slug, .guid] | @tsv' "firefox/extensions.yaml"))
    for ((i=0; i<${#extensions[@]}; i+=2)); do
        slug="${extensions[i]}"
        guid="${extensions[i+1]}"
        msg "cyan" "Installing: $slug"
        install_firefox_extension "$slug" "$guid"
    done
}

function configure_iterm() {
    msg "blue" "Configuring iTerm2..."
    if [[ -f "$ITERM_PLIST" ]]; then
        cp -f "$ITERM_PLIST" "${ITERM_PLIST}.backup"
    fi

    defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
    defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$SCRIPT_DIR/iTerm2"
    defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -integer 2
    defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true

    msg "green" "iTerm2 configured. Please restart iTerm2"
}


# CONFIG_OPTIONS=$(
#     gum choose --no-limit --selected=* --header "What to configure?" \
#         "Default packages" \
#         "Firefox Extensions" \
#         "iTerm2" \
#         "VSCode" \
#         "ZSH"
# )

# if [[ $CONFIG_OPTIONS == *"VSCode"* ]]; then
#     VSCODE_CONFIG=$(
#         gum choose --no-limit --selected=* --header "VSCode configuration" \
#         "Install plugins" \
#         "Setup keybindings" \
#         "Override settings"
#     )
# fi


function main() {
    local DO_FIREFOX=""
    local DO_HELM=""
    local DO_ITERM=""
    local DO_KREW=""
    local DO_PACKAGES=""
    local DO_VSCODE=""
    local DO_ZSH=""

    # Capture arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--all)       DO_ALL="1";;
            -f|--firefox)   DO_FIREFOX="1" ;;
            -i|--iterm)     DO_ITERM="1" ;;
            -k|--krew)      DO_KREW="1" ;;
            -m|--helm)      DO_HELM="1" ;;
            -p|--packages)  DO_PACKAGES="1" ;;
            -v|--vscode)    DO_VSCODE="1" ;;
            -z|--zsh)       DO_ZSH="1" ;;
            -h|--help)      usage 0 ;;
            *)              usage 1 ;;
        esac
        shift
    done

    [[ -n "$DO_PACKAGES" || -n "$DO_ALL" ]] && install_system_packages
    [[ -n "$DO_ZSH"      || -n "$DO_ALL" ]] && configure_zsh
    [[ -n "$DO_KREW"     || -n "$DO_ALL" ]] && install_krew_plugins
    [[ -n "$DO_HELM"     || -n "$DO_ALL" ]] && install_helm_plugins
    [[ -n "$DO_VSCODE"   || -n "$DO_ALL" ]] && configure_vscode
    [[ -n "$DO_FIREFOX"  || -n "$DO_ALL" ]] && install_firefox_extensions
    [[ -n "$DO_ITERM"    || -n "$DO_ALL" ]] && configure_iterm
}

main "$@"
