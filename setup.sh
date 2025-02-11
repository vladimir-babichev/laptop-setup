#!/usr/bin/env bash

ITERM_PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
MOZILLA_ADDONS_API="https://addons.mozilla.org/api/v5"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
VSCODE_DIR="$HOME/Library/Application Support/Code/User"
ZSH_CONFIG_DIR="$HOME/.config/zsh"


function usage() {
    cat <<EOF
Usage: $(basename "$0") [options]
Options:
    -a  Install all components
    -b  Install brew packages
    -f  Install Firefox extensions
    -h  Install Helm plugins
    -i  Configure iTerm2
    -k  Install Krew plugins
    -v  Configure VSCode
    -z  Configure ZSH
EOF
    exit 0
}

function fix_permissions() {
    sudo chmod +a "user:${USER} allow list,add_file,search,add_subdirectory,delete_child,readattr,writeattr,readextattr,writeextattr,readsecurity,file_inherit,directory_inherit" /usr/local/bin
}

function install_system_packages() {
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

    else
        echo "Extension '$name' not found"
    fi

    sleep 10
    rm -f "$TEMP_XPI"
}

install_firefox_extensions() {
    msg "blue" "Installing Firefox extensions..."
    [[ -f "$SCRIPT_DIR/firefox/extensions.yaml" ]] || return 1

    while IFS=$'\t' read -r slug guid; do
        msg "cyan" "Installing: $slug"
        install_firefox_extension "$slug" "$guid"
    done <<<"$(yq -r '.extensions[] | [.slug, .guid] | @tsv' "firefox/extensions.yaml")"
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


CONFIG_OPTIONS=$(
    gum choose --no-limit --selected=* --header "What to configure?" \
        "Default packages" \
        "Firefox Extensions" \
        "iTerm2" \
        "VSCode" \
        "ZSH"
)

if [[ $CONFIG_OPTIONS == *"VSCode"* ]]; then
    VSCODE_CONFIG=$(
        gum choose --no-limit --selected=* --header "VSCode configuration" \
        "Install plugins" \
        "Setup keybindings" \
        "Override settings"
    )
fi

# Configure access to finastra-platform with gh

