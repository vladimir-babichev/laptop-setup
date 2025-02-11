# Dev Laptop Setup

Complete Dev Mac bootstrap:

* Homebrew Packages and Casks
* Apps from Mac App Store
* Dotfiles linking and Zsh configuration
* Firefox extensions
* iTerm2 configurations
* Krew & Helm plugins installation
* VSCode configuration, extensions, keybindings

## TL;DR

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vladimir-babichev/laptop-setup/main/bootstrap.sh)
```
See [`bootstrap.sh`](bootstrap.sh) for details.

## Usage

### Complete bootstrap

Ideal for clean laptop setup.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/vladimir-babichev/laptop-setup/main/bootstrap.sh)
```
See [`bootstrap.sh`](bootstrap.sh) for details.

### Parametrised installation

Works great when you want to install only specific parts.

```bash
git clone https://github.com/vladimir-babichev/laptop-setup.git
./setup.sh -a
```

```bash
$ ./setup.sh -h
Usage: setup.sh [options]

This script bootstraps a Dev laptop.
Options:
  -a, --all           Install everything
  -f, --firefox       Install Firefox extensions
  -i, --iterm         Configure iTerm2
  -k, --krew          Install Krew plugins
  -m, --helm          Install Helm plugins
  -p, --packages      Install default packages with Homebrew
  -s, --mas           Install Mac App Store applications
  -v, --vscode        Install VSCode extensions, keybindings, settings
  -z, --zsh           Install Zinit, link dotfiles, configure ZSH
  -h, --help          Show this message and exit

Examples:
  ./setup.sh --packages --zsh --helm
```

### Prompted setup

If you want to be guided through setup.

```bash
git clone https://github.com/vladimir-babichev/laptop-setup.git
./setup.sh
```

## Directory Structure

* **brew/** – Homebrew Brewfiles for different setups.
* **dotfiles/** – Custom configuration files (Zsh, gitignore, etc.).
* **firefox/** – Firefox extensions configuration.
* **helm/** – Helm plugins configuration.
* **iTerm2/** – iTerm2 configuration plist.
* **krew/** – Krew plugins definitions.
* **vscode/** – VSCode settings, keybindings, and extensions.

## Shortcuts

### Terminal

| Shortcut            | Command                              |
| ------------------- | ------------------------------------ |
| `↑`                 | Search command history backward      |
| `↓`                 | Search command history forward       |
| `⌥` + `←`           | Move cursor one word backward        |
| `⌥` + `→`           | Move cursor one word forward         |
| `Ctrl` + `W`        | Delete one word backward             |
| `Esc` + `Backspace` | Delete one part of the work backward |
| `⌘` + `K`           | Clear terminal screen                |
| `fn` + `←`          | Move to the beginning of the line    |
| `fn` + `→`          | Move to the end of the line          |
| `Ctrl` + `R`        | Fuzzy search across history          |


### iTerm2

| Shortcut                | Command                                  |
| ----------------------- | ---------------------------------------- |
| `⌘` + `⌥` + `I`         | Broadcast input to all iTerm2 panes      |
| `⌘` + `/`               | Find Cursor                              |
| `⌘` + `T`               | New Tab                                  |
| `⌘` + `W`               | Close Tab or Window                      |
| `⌘` + `D`               | Split Window Vertically (same profile)   |
| `⌘` + `Shift` + `D`     | Split Window Horizontally (same profile) |
| `⌘` + `Enter`           | Full Screen                              |
| `⌘` + `Shift` + `Enter` | Maximize a pane                          |
| `⌘` + `]` , `⌘` + `[`   | Go to Split Pane by Order of Use         |
| `⌘` + `←`               | Previous Tab                             |
| `⌘` + `→`               | Next Tab                                 |


### VSCode

| Shortcut        | Command                          |
| --------------- | -------------------------------- |
| `F9`            | Sort lines alphabetically        |
| `⌘`+`K` `⌘`+`U` | Transform selection to uppercase |
| `⌘`+`K` `⌘`+`L` | Transform selection to lowercase |
