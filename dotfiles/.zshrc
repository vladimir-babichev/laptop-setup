setopt autocd              # change directory just by typing its name
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense

HISTSIZE=1000000
SAVEHIST=$HISTSIZE
setopt extended_history       # save timestamp of command
setopt share_history          # share history between all sessions
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it

unsetopt beep              # be quiet!

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
autoload -Uz +X compinit && compinit

###
#   Brew
###

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_AUTO_UPDATE=1
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix findutils)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix gnu-sed)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix gnu-tar)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix grep)/libexec/gnubin:$PATH"
export PATH="~/bin:$PATH"
eval "$(brew shellenv zsh)"


###
#   Zinit
###

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


###
#   Zinit plugins
###

zinit light zdharma-continuum/fast-syntax-highlighting
zinit light wfxr/forgit
# zinit light marlonrichert/zsh-autocomplete

export YSU_MESSAGE_POSITION="after"
zinit light MichaelAquilina/zsh-you-should-use


###
#   Krew
###

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"


###
#   Load custom zsh configurations
###

ZSH_CONFIG_DIR="${HOME}/.config/zsh"

if [[ -L "$ZSH_CONFIG_DIR" ]] || [[ -d "$ZSH_CONFIG_DIR" ]]; then
    for config_file in ${ZSH_CONFIG_DIR}/*.zsh(N.:A); do
        source "$config_file"
    done
fi

eval "$(starship init zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init zsh --cmd cd)"
