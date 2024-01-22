#!/usr/bin/env bash

# setup options for the script
set -euo pipefail

# setup environment variables
DOTHUB_LOG_FILE=${DOTHUB_LOG_FILE:-$HOME/.dothub.log}
# DOT_DIR=${DOT_DIR:-${1:-"./"}}
# PACKAGE_MANAGER=y${PACKAGE_MANAGER:-yay}
PACKAGE_MANAGER=yay
PACKAGE_LIST=("git" "curl" "wget" "zsh" "tmux" "foot")
INSTALL_COMMAND="yay -S"
DOTFILE_GIT_REPO="https://github.com/ashish-kus/dotfiles"




### Printing Functuins

# color variables
red='\033[0;31m'
green='\033[0;32m'
purple='\033[0;35m'
normal='\033[0m'

# Function to print a message
_w() {
    local -r text="${1-}"
    echo -e "$text"
  }

# Function to print an announcement message
_a() { _w " > $1"; }                  

# Function to print an error message (with red color)
_e() { _a "${red}$1${normal}"; }

# Function to print a success message (with green color)
_s() { _a "${green}$1${normal}"; }

# Function to prompt the user for input
_q() { read -rp "🤔 $1: " "$2"; }

# Function to log messages to a logfile
_log() {
  if [ ! -f $DOTHUB_LOG_FILE ]; then
      _e "DOTHUB_LOG_FILE not Found"
      touch $DOTHUB_LOG_FILE
      _s "DOTHUB_LOG_FILE created ~/.dothub.log"
  fi
	log_name="$1"
	current_date=$(date "+%Y-%m-%d %H:%M:%S")

	echo "----- $current_date - $log_name -----" >>"$DOTHUB_LOG_FILE"

	while IFS= read -r log_message; do
		echo "$log_message" >>"$DOTHUB_LOG_FILE"
	done

	echo "" >>"$DOTHUB_LOG_FILE"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


setup_package_manager() {
    if command_exists apt; then
        PACKAGE_MANAGER="apt"
        INSTALL_COMMAND="sudo apt -y install"
    elif command_exists dnf; then
        PACKAGE_MANAGER="dnf"
        INSTALL_COMMAND="sudo dnf -y install"
    elif command_exists yum; then
        PACKAGE_MANAGER="yum"
        INSTALL_COMMAND="yes | sudo yum install"
    elif command_exists yay; then
        PACKAGE_MANAGER="yay"
        INSTALL_COMMAND="yay -S --noconfirm"
    elif command_exists pacman; then
        PACKAGE_MANAGER="pacman"
        INSTALL_COMMAND="sudo pacman -S --noconfirm"
    else
        _e "Unsupported package manager. Please install packages manually."
        exit 1
    fi
}

# Function to install one or more packages
install_packages() {
    local package_manager="$PACKAGE_MANAGER"
    shift # Remove the first argument (package manager) from the list
    local packages=("$@")

    if [ "${#packages[@]}" -eq 0 ]; then
        echo "No packages specified to install."
        return
    fi

    for package in "${packages[@]}"; do
        if ! command_exists "$package"; then
          echo "Installing $package using $package_manager"
          yes | $INSTALL_COMMAND $package 2>&1 | _log "Installing $package" 
        else

            echo "$package is already installed."
        fi
    done
}


create_symlinks(){
    directory_list=$(find $DOT_DIR -mindepth 1 -not -name 'install.sh' )
    # Iterate over the list using a for loop

    for entry in $directory_list; do
      # # Remove "./" and replace it with $HOME/
      # modified_entry="${}"
      modified_entry="$HOME/${entry#./}"
      # echo "Modified Entry: $modified_entry"
       ln -sf "$(pwd)/${entry#./}" "$modified_entry"
      echo "$(pwd)/${entry#./}" "$modified_entry"
      _log "$entry"
      # # Add your additional logic or commands here
  done
  }

main() {
_w "  ┌──────────────────────────────────────┐"
_w "~ │ 🚀 Welcome to the ${green}dothub${normal} installer!  │ ~"
_w "  └──────────────────────────────────────┘"
_w
_q 'Where do you want your dotfiles to be located? (default ~/.dotfiles)' "DOTFILES_PATH"
DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
DOTFILES_PATH="$(eval echo "$DOTFILES_PATH")"
export DOTFILES_PATH="$DOTFILES_PATH" # path might contain variables or special characters that 
                                      # need to be expanded or interpreted correctly.                                      
DOTHUB_CONFIG_PATH="$DOTFILES_PATH/dothub.conf"

install_packages "git" "curl"

}
main
