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

# Artifactory Token Expiry Checker
check_artifactory_token() {
    local input="$1"

    # If no token is provided, check if stdin is being piped
    if [ -z "$input" ]; then
        if [ ! -t 0 ]; then
            input=$(cat)
        else
            echo -e "${Ered}Error: No token provided.${Eclr}"
            echo "Usage: check_artifactory_token <TOKEN_OR_BASE64_STRING>"
            return 1
        fi
    fi

    # Clean wrapping whitespace, quotes, and newlines
    input=$(echo "$input" | tr -d '\n\r"'\'' ')

    # 1. First base64 decode attempt
    local decoded1
    decoded1=$(echo "$input" | base64 -d 2>/dev/null)

    if [ -n "$decoded1" ]; then
        # Case 1: Decoded string starts directly with "reftkn"
        if [[ "$decoded1" =~ ^reftkn:[0-9]{2}: ]]; then
            input="$decoded1"

        # Case 2: Decoded string is "username:token" (where token is another base64 string)
        elif [[ "$decoded1" =~ ^[^:]+:(.+)$ ]]; then
            local nested_base64="${BASH_REMATCH[1]}"
            local decoded2
            decoded2=$(echo "$nested_base64" | base64 -d 2>/dev/null)

            # If the double-decoded token is a valid reftkn, use it
            if [[ "$decoded2" =~ ^reftkn:[0-9]{2}: ]]; then
                input="$decoded2"
            fi
        fi
    fi

    # 3. Extract the Unix Epoch Timestamp and format it
    if [[ "$input" =~ ^reftkn:[0-9]{2}:([0-9]+): ]]; then
        local epoch="${BASH_REMATCH[1]}"
        local human_date
        human_date=$(date -d "@$epoch" 2>/dev/null || date -r "$epoch" 2>/dev/null)

        echo -e "${Egrn}✔ Valid Artifactory Reference Token Detected${Eclr}"
        echo -e "${Eblu}Expiry Epoch:${Eclr} $epoch"
        echo -e "${Eblu}Expiry Date: ${Eclr} \e[1m$human_date\e[0m"
    else
        echo -e "${Ered}✖ Error: Not a valid Artifactory token or Base64 encoded token config.${Eclr}"
        return 1
    fi
}


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

gpull() {
  for dir in */; do
    if [ -d "${dir}.git" ]; then
      echo "📦 Checking: ${dir%/}"

      # 1. Check for uncommitted changes (if output is not empty, there are changes)
      if [ -n "$(git -C "$dir" status --porcelain)" ]; then
        echo "⚠️  Skipping: Repository has uncommitted changes."
        echo "----------------------------------------"
        continue # Move to the next directory
      fi

      # 2. Get the currently active branch
      current_branch=$(git -C "$dir" branch --show-current)
      echo "🌿 Current branch: $current_branch"

      # 3. If we are NOT on main, check it out first
      if [ "$current_branch" != "main" ]; then
        echo "🔀 Branch is '$current_branch'. Switching to 'main'..."

        # Suppress checkout output, but catch errors (like if 'main' doesn't exist)
        if git -C "$dir" checkout main >/dev/null 2>&1; then
           echo "⬇️  Pulling latest changes..."
           git -C "$dir" pull
        else
           echo "❌ Error: Could not switch to 'main' (Does this repo use 'master'?). Skipping."
        fi
      else
        # We are already on main
        echo "⬇️  Already on 'main'. Pulling latest changes..."
        git -C "$dir" pull
      fi

      echo "----------------------------------------"
    fi
  done
  echo "✅ All repositories processed!"
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

phoneping() {
  adb shell <<EOF
cmd notification post -S bigtext -t 'Ping' 'Tag' 'Liveness Probe'
EOF
}


bash_prompt

local_bin_path_add

alias update="sudo apt update && sudo apt upgrade -y; sudo apt-get update && sudo apt-get upgrade -y;"

alias currentbranch='git branch | grep \* | sed "s/* //"'

alias checktoken=check_artifactory_token

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

