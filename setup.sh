#!/usr/bin/env bash

# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install gum
if ! command -v gum &> /dev/null; then
    echo "Installing gum..."
    brew install gum
fi

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

if [[ $CONFIG_OPTIONS == *"Default packages"* ]]; then
    brew bundle --file brew/Brewfile-system
fi

if [[ $CONFIG_OPTIONS == *"ZSH"* ]]; then
    # Install Zinit
    bash -c "$(
        curl --fail --show-error --silent --location \
            https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh
    )"
    zsh -i -c 'zinit self-update'

    # Link configuration files
    find dotfiles -type f -depth 1 -exec ln -sf "$PWD/{}" "$HOME/" \;
    find dotfiles -type d -depth 1 -exec sh -c 'mkdir -p "$HOME/${1#dotfiles/}"' _ {} \;
    find dotfiles -depth 2 -exec sh -c 'ln -sf "$PWD/{}" "$HOME/${1#dotfiles/}"' _ {} \;
fi

if [[ $CONFIG_OPTIONS == *"VSCode"* ]]; then
    VSCODE_SETTINGS_DIR="$HOME/Library/Application Support/Code/User"

    # Configure Firefox plugins
    if [[ $VSCODE_CONFIG == *"Install plugins"* ]]; then
        brew bundle --file brew/Brewfile-vscode
    fi

    if [[ $VSCODE_CONFIG == *"Setup keybindings"* ]]; then
        ln -sf "$PWD/vscode/keybindings.json" "$VSCODE_SETTINGS_DIR/"
    fi

    if [[ $VSCODE_CONFIG == *"Override settings"* ]]; then
        ln -sf "$PWD/vscode/settings.json" "$VSCODE_SETTINGS_DIR/"
    fi
fi

if [[ $CONFIG_OPTIONS == *"iTerm"* ]]; then
    echo $PWD/iTerm2/*plist | pbcopy

    ITERM_INSTRUCTIONS='
# Configure iTerm2
1. Open iTerm2 Settings by pressing `Cmd + ,`
2. Go to **"General"** -> **"Settings"**
3. Select **"Load preferences from a custom folder or URL"**
4. Press `Cmd + V` and hit `Enter`
5. Select **"Automatically"** from save changes dropdown
6. Close settings
'
    gum style \
	--border-foreground 212 --border double \
	--margin "1 2" --padding "2 4" \
    "$(gum format -- "$ITERM_INSTRUCTIONS")"
fi

exit 0

# Configure Firefox plugins
# Configure iTerm2
# Configure access to finastra-platform with gh

