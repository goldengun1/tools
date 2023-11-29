#!/bin/bash

set -e

git pull
cp ./.custom_bash_configurations.sh ~/
chmod +x ~/.custom_bash_configurations.sh

if grep -iq "^source ~/." ~/.bashrc; then
        echo -e "Alredy modified .bashrc file \e[34m-- LOADING EXISTING --\e[0m";
    else
        echo "source ~/.custom_bash_configurations.sh" >> ~/.bashrc;
        echo -e "Loaded new profile \e[34m-- SUCCESS --\e[0m";
    fi

echo -e "\e[32mDONE\e[0m"
source ~/.bashrc