#!/usr/bin/env bash

# Source: https://github.com/aboqasem/dotfiles/blob/main/setup/macos.zsh

osascript -e 'tell application "System Settings" to quit'

# Set dark mode
defaults write NSGlobalDomain AppleInterfaceStyle -string Dark

# Double-click a window's title bar to:
#   - Maximize
#   - Minimize
#   - None
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

# Set a blazingly fast keyboard repeat rate. Default is 2 (30 ms)
# defaults write NSGlobalDomain KeyRepeat -int 1

# Default is 15 (225 ms)
defaults write NSGlobalDomain InitialKeyRepeat -int 10

# Disable "Mission Control" keyboard shortcut (^↑), used in VSCode
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:32:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:34:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist

# Disable "Application windows" keyboard shortcut (^↓), used in VSCode
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:33:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist
/usr/libexec/PlistBuddy -c "Set :AppleSymbolicHotKeys:35:enabled false" ~/Library/Preferences/com.apple.symbolichotkeys.plist


###
#   Activity Monitor
###

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
