alias zc="vim ~/.zshrc"
alias zcr="vim ~/.zshrc && reload"
alias shrug="echo '¯\_(ツ)_/¯' | pbcopy";

alias brewski='brew update && brew upgrade && brew upgrade brew-cask; brew cleanup; brew doctor'
alias "cd.."="cd .."

# Git
alias status="git status"
alias stash="git stash"
alias nah="git reset --hard && git clean -df"
alias pull="git pull"
alias push="git push"
alias merge="git merge $1"
alias checkout="git checkout $1"
alias gs="git status"
alias commit="git commit -m $1"
alias wip="cosh 'wip'"

# Tmux
alias tma='tmux attach -d -t'

alias reload="source ~/.zshrc && echo 'ZSH config reloaded'"
alias dev="cd ~/code/"
alias sshkey="cat ~/.ssh/id_rsa.pub |pbcopy"
alias valias="vim ~/.dotfiles/zsh/alias.zsh && reload"

# Docker
alias dr="docker-compose down && docker-compose up -d --build"
