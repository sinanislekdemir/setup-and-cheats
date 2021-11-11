case $- in
    *i*) ;;
      *) return;;
esac

HISTCONTROL=ignoreboth

shopt -s histappend

HISTSIZE=10000
HISTFILESIZE=20000

shopt -s checkwinsize

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

if [ "$color_prompt" = yes ]; then
    PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] \[\e[91m\]\$(parse_git_branch)\[\e[00m\]$ "
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

PS1="\u:\w>\[$(tput sgr0)\]"
# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

cdp () {
    cd "/home/sislekdemir/workspace/iceye/$1"
}

hs () {
    cat ~/.bash_history | grep $1
}

csv () {
    column -s, -t < $1 | less -#2 -N -S
}

kdelete () {
    kubectl config get-contexts
    read -p "Are you sure?" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        kubectl delete $@
    fi
}

alias adocker="aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 368554718146.dkr.ecr.eu-central-1.amazonaws.com"

help () {
    echo "Alias List
    aa       = AWS Auth Edit
    adocker  = Login to AWS Docker
    c        = clikan - todo list
    cdp      = Change directory to project
    hs       = search in history
    k        = kubectl
    kap      = k apply -f
    kbashp   = k bash <pod> <container>
    kbashs   = k bash <pod> <container>
    dp       = delete pod prod
    ds       = delete pod staging
    kcgc     = k config get-contexts
    kcuc     = k config use-context
    kd       = k describe
    kdelete  = Delete pod with checking context
    kdpp     = k describe pod -n production
    kdps     = k describe pod -n staging
    kgp      = k get pods
    kgpp     = k get pods -n production
    kgps     = k get pods -n staging
    klogp    = k logs -f -n production
    klogs    = k logs -f -n staging
    pips     = Pip Search
    p        = python3
    siksok   = remove duplicates
    "
}

kbashp () {
    kubectl exec -n pallas-production $1 -c $2 -it -- /bin/bash
}

kbashs () {
    kubectl exec -n pallas-staging $1 -c $2 -it -- /bin/bash
}

kbashpt () {
    kubectl exec -n telemetry-production $1 -c $2 -it -- /bin/bash
}

kbashst () {
    kubectl exec -n telemetry-staging $1 -c $2 -it -- /bin/bash
}

dp ()
{
    kubectl delete pod -n pallas-production $1
}

ds ()
{
    kubectl delete pod -n pallas-staging $1
}

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/sislekdemir/go/bin
export DOCKER_HOST=unix:///run/user/1572866986/docker.sock
export AWS_PROFILE=gsw_Developer

alias nospace='for f in *\ *; do mv "$f" "${f// /_}"; done'
alias siksok="fdupes -r -f . | grep -v '^$' | xargs rm -v"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias k=kubectl
alias kcgc="k config get-contexts"
alias kcuc="k config use-context"
alias kgps="k get pods --namespace=pallas-staging"
alias kgpp="k get pods --namespace=pallas-production"
alias kgpst="k get pods --namespace=telemetry-staging"
alias kgppt="k get pods --namespace=telemetry-production"
alias pips="python -m pypi_search"
alias kdps="KUBECONFIG=/home/sislekdemir/mo.yaml k describe pod --namespace=pallas-staging"
alias kdpp="k describe pod --namespace=pallas-production"
alias klogs="KUBECONFIG=/home/sislekdemir/mo.yaml k logs -f --namespace=pallas-staging"
alias klogp="k logs -f --namespace=pallas-production"
alias klogst="KUBECONFIG=/home/sislekdemir/mo.yaml k logs -f --namespace=telemetry-staging"
alias klogpt="k logs -f --namespace=telemetry-production"

alias c=clikan
alias p="python3"

eval "$(direnv hook bash)"
alias aa="aws sso login --profile gsw_Developer"

export KUBECONFIG=/home/sislekdemir/mo.yaml
alias watch='watch '
export OP_SESSION_iceye="8Wnf2wSumf3yLB3w-FaXNWFV3mDfHbZWOTv0lTGdP70"

alias install_pyls="pip install 'python-language-server[all]' pyls-isort pyls-mypy pyls-black"
export XDG_CONFIG_HOME=$HOME/.config

alias x='xdg-open'
alias xc='xclip -selection c'
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

jurl () {
    curl $@ -H 'accept: application/json' | jq
}
alias em='emacs -nw -q'
alias ns='k config set-context --current --namespace'
alias gp='git push origin HEAD'
