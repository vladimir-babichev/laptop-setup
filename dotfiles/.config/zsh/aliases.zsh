alias zrld="source ~/.zshrc"

###
#   System
###

alias ..='cd ..'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../..'

alias cat='bat --decorations=never --theme OneHalfDark --paging=never'
alias grep='grep --color'
alias history='history -i'
alias less='less -R'
alias ll='eza --group-directories-first --icons -lag'
alias ls='eza --group-directories-first --icons'
alias man='batman'
alias myip='dig +short myip.opendns.com @resolver1.opendns.com'
alias ncdu='ncdu --color dark -x'
alias tree="tree -a -I .git --dirsfirst --sort name"
alias vi="nvim"
alias vim="nvim"
alias wsn="wget -S -O/dev/null"

alias hideFiles='defaults write com.apple.finder AppleShowAllFiles NO;  killall Finder /System/Library/CoreServices/Finder.app'
alias showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'


###
#   Git
###

alias gad='git add'
alias gada='git add -A'
alias gbr='git branch'
alias gci='git commit'
alias gco='git checkout'
alias gdf='git diff'
alias gg='git grep'
alias glg2='git log --date-order --all --graph --name-status --format="%C(green)%H%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'
alias glg='git log --date-order --all --graph --format="%C(green)%h%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'
alias gpl='git pull'
alias gpu='git push'
alias grb='git rebase'
alias gst='git status'


###
#   Docker
###

alias dec='docker exec -ti'
alias dps='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'

###
#   Azure
###

alias azl='az login -o table --only-show-errors'
