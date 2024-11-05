#!/bin/bash

blk='\[\033[01;30m\]'   # Black
red='\[\033[01;31m\]'   # Red
grn='\[\033[01;32m\]'   # Green
ylw='\[\033[01;33m\]'   # Yellow
cyn='\[\033[01;34m\]'   # Blue
pur='\[\033[01;35m\]'   # Purple
blu='\[\033[01;36m\]'   # Cyan
wht='\[\033[01;37m\]'   # White
clr='\[\033[00m\]'      # Reset

function git_branch() {
    if [ -d "$(git rev-parse --git-dir 2>/dev/null)" ]; then
        printf "%s" "($(git branch 2> /dev/null | awk '/\*/{print $2}'))";
    fi
}

function bash_prompt(){
    if [ $(id -u) -eq 0 ];
    then # you are root, make the prompt red
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]'${red}'\u'${grn}'@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] '${ylw}'$(git_branch)'${clr}'\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]'${blu}'\u'${grn}'@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] '${ylw}'$(git_branch)'${clr}'\$ '
    fi
}

function venv_prompt_update(){
    sed -r -i 's/\s*PS1=\"\((.*)/PS1="\\[\\033[01;35m\\](.venv) \\[\\033[00m\\]${PS1:-}"/' "$1"
}

bash_prompt

alias update="sudo apt update && sudo apt upgrade -y; sudo apt-get update && sudo apt-get upgrade -y;"

alias currentbranch='git branch | grep \* | sed "s/* //"'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

#network aliases
alias myip='host myip.opendns.com resolver1.opendns.com | egrep -i "myip.opendns.com has address" | sed -r "s/myip.opendns.com has address\s*(.*)/\1/"'


#ls aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias disk='df -H | egrep -i "Filesystem.*|dev/sd.*|dev/nvm.*" --color=never'
alias scale='echo -e "Defautl configurations for applications scale override\r\n/usr/share/applications/"'
alias gitlog='git log --all --graph --decorate'
