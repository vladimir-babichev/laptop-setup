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
