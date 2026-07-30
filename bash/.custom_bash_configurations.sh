#!/bin/bash

# For MacOS
# blk='\033[1;30m'   # Black
# red='\033[1;31m'   # Red
# grn='\033[1;32m'   # Green
# ylw='\033[1;33m'   # Yellow
# cyn='\033[1;34m'   # Blue
# pur='\033[1;35m'   # Purple
# blu='\033[1;36m'   # Cyan
# wht='\033[1;37m'   # White
# clr='\033[0m'      # Reset color

# For Linux PS1
blk='\[\033[01;30m\]'   # Black
red='\[\033[01;31m\]'   # Red
grn='\[\033[01;32m\]'   # Green
ylw='\[\033[01;33m\]'   # Yellow
cyn='\[\033[01;34m\]'   # Blue
pur='\[\033[01;35m\]'   # Purple
mgn='\[\033[1;38;2;255;0;255m\]' # Magenta
blu='\[\033[01;36m\]'   # Cyan
wht='\[\033[01;37m\]'   # White
clr='\[\033[00m\]'      # Reset

# For echo printing
Egrn='\033[01;32m'       # Green
Ered='\033[01;31m'       # Red
Eylw='\033[01;33m'       # Yellow
Eblu='\033[01;36m'
Epur='\033[01;35m'      # Purple
Emgn='\033[1;38;2;255;0;255m' # Magenta
Eclr='\033[00m'         # Reset

function local_bin_path_add() {
  local bin_dir="$HOME/.bin"  # Store the directory in a local variable
  local path_value="$PATH" #Store the PATH in a local variable
  # Check if the directory exists
  if [ -d "$bin_dir" ]; then
    # Check if the directory is already in the PATH
    if [[ ":${path_value}:" != *":${bin_dir}:"* ]]; then
      # Add the directory to the PATH
      export PATH="${bin_dir}:${path_value}"
      echo "Local bin added to PATH"
    else
      echo "$bin_dir is already in PATH"
    fi
  else
    echo "$bin_dir does not exist\r\n"
    echo "Creating local bin directory..."
    mkdir -p "${bin_dir}"
    export PATH="${bin_dir}:${path_value}"
    echo "Created local bin and add to PATH"
  fi
}

function git_branch() {
    if [ -d "$(git rev-parse --git-dir 2>/dev/null)" ]; then
        local branch
        branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo "(no branch)")
        printf "(%s)" "$branch";
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
    sed -r -i 's/\s*PS1=\"\((.*)/PS1="\\[\\033[1;38;2;255;0;255m\\](.venv) \\[\\033[00m\\]${PS1:-}"/' "$1"
}

phone-cast() {
  if ! command -v scrcpy >/dev/null 2>&1; then
    echo "Error: 'scrcpy' command not found. Please install it first."
    return 1
  fi
  scrcpy "$@" > /dev/null 2>&1 &
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

#directory traversal aliases
alias ..='cd ../'
alias ...='cd ../../'
alias ....='cd ../../../'
alias .....='cd ../../../../'

