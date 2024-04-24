#!/usr/bin/env bash

set -oue pipefail
# set -x pipefail
DOTMASTER_LOG_FILE=${DOTMASTER_LOG_FILE:-$HOME/.dotmaster.log}
PACKAGE_LIST=("git" "curl" "wget" "zsh" "tmux" "foot")

# color variables
red='\033[0;31m'
green='\033[0;32m'
purple='\033[0;35m'
normal='\033[0m'

# messages & alerts

_w() {
    local -r text="${1-}"
    echo -e "$text"
  }
_a() { _w " > $1"; }                  
_e() { _a "${red}$1${normal}"; }
_s() { _a "${green}$1${normal}"; }
_q() { read -rp "? $1: " "$2"; }

# loging Function
_log() {
  if [ ! -f $DOTMASTER_LOG_FILE ]; then
      _e "$DOTMASTER_LOG_FILE not Found"
      touch $DOTMASTER_LOG_FILE
      _s "DOTMASTER_LOG_FILE_LOG_FILE created ~/.dotmaster.log"
  fi
	log_name="$1"
	current_date=$(date "+%Y-%m-%d %H:%M:%S")
	echo "----- $current_date - $log_name -----" >>"$DOTMASTER_LOG_FILE"
	while IFS= read -r log_message; do
		echo "$log_message" >>"$DOTMASTER_LOG_FILE"
	done
	echo "" >>"$DOTMASTER_LOG_FILE"
}

# command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Setting up PACKAGE MANAGER
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

# installing packages list 
install_packages() {
    local package_manager="$PACKAGE_MANAGER"
    packages=( "$@" )
    if [ "${#packages[@]}" -eq 0 ]; then
        _e "No packages specified to install."
        return
    fi
    for package in "${packages[@]}";
        do
          if ! command_exists "$package"; then
            _e "Uh-oh! $package is missing."
            _a "Installing $package using $package_manager"
            yes | $INSTALL_COMMAND "$package" 2>&1 | _log "installing $package"
            # $INSTALL_COMMAND $package 2>&1
            if [ $? == 0 ]; then _s "$package installed using $package_manager" ;else _e "can't install $package"; (exit 1); fi;
          else
              _s "$package is already installed."
          fi
    done
}


installing_repo() {
  
    if [ -d "$DOTFILES_PATH" ]; then
      _e "$DOTFILES_PATH already exists"
        local backup_dir="$DOTFILES_PATH/../.dotmaster_backup"
        if [ -d "$backup_dir" ]; then
          _a "backup directory exists ie $backup_dir"
          mv "$DOTFILES_PATH" "$backup_dir/backup_$(date '+%Y%m%d%H%M%S')"
          _s "backup created at $HOME/.dotmaster_backup_timestamp"
        else
          _a "creating backup $DOTFILES_PATH/../.dotmaster_backup_timestamp/ "
          mkdir -p "$backup_dir"
          mv "$DOTFILES_PATH" "$backup_dir/"
          _s "backup created at $HOME/.dotmaster_backup_timestamp"
        fi
    fi
    if command_exists "git"; then
        _a "cloning $1"
        git clone "$1" "$DOTFILES_PATH" 2>&1 | _log "cloning dotfile REPOSITORY"
    else
        _e "git not installed"
    fi
}

main() {
local use_git_repo=false
local use_local_dir=false

while getopts ":u:d:-:" opt; do
    case $opt in 
        u | -u)
            if [ -z "$OPTARG" ]; then
                _e "Error: Argument missing from option -$opt"
                exit 1
            fi
            echo "url $OPTARG"
            use_git_repo=true
            ;;
        d | -d)
            if [ -z "$OPTARG" ]; then
                _e "Error: Argument missing from option -$opt"
                exit 1
            fi
            use_local_dir=true
            DOTDIR=$OPTARG
            echo "local $DOTDIR"
            ;;
        -)
            case "${OPTARG}" in
                *)
                    _e "Invalid option: --$OPTARG"
                    exit 1
                    ;;
            esac
            ;;
        \?)
            _e "Invalid option: -$OPTARG"
            exit 1
            ;;
        :)
            _e "Option -$OPTARG requires an argument."
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

if $use_git_repo && $use_local_dir; then
    _e "Error: Both URL and directory options cannot be used together"
    exit 1
elif $use_git_repo; then
    # _s "Using git repo: $DOTFILE_GIT_REPO"
    _s "Using git repo: "
    _s $use_git_repo
elif $use_local_dir; then
    _s "Using local directory: "
    _s $use_local_dir
    # _s "Using local directory: $DOTFILES_PATH"
fi
}
main "$@"

