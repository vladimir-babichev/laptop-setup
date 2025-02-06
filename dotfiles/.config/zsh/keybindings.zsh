bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line


# ESC + Backspace behaviour compatible with Bash
x-bash-backward-kill-word(){
    WORDCHARS='' zle backward-kill-word
}
zle -N x-bash-backward-kill-word
bindkey '\e^?' x-bash-backward-kill-word

# Delete full word on Ctrl + W
x-backward-kill-word(){
    WORDCHARS='*?_-[]~\!#$%^(){}<>|`@#$%^*()+:?.' zle backward-kill-word
}
zle -N x-backward-kill-word
bindkey '^W' x-backward-kill-word

# Search history for a matches up to the current cursor position (Arrow UP)
autoload -U up-line-or-beginning-search
zle -N up-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search

# Search history for a matches up to the current cursor position (Arrow Down)
autoload -U down-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search # Down
