#!/usr/bin/env bash

# setup options for the script
set -euo pipefail

# setup environment variables
DOTMASTER_LOG_FILE=${DOTMASTER_LOG_FILE:-$HOME/.dotmaster.log}
# DOT_DIR=${DOT_DIR:-${1:-"./"}}
# PACKAGE_MANAGER=y${PACKAGE_MANAGER:-yay}
PACKAGE_LIST=("git" "curl" "wget" "zsh" "tmux" "foot")
# INSTALL_COMMAND="yay -S"
# DOTFILE_GIT_REPO="https://github.com/ashish-kus/dotfiles"

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
    packages=( "$@" )

    if [ "${#packages[@]}" -eq 0 ]; then
        _e "No packages specified to install."
        return
    fi

    for package in "${packages[@]}";
        do
          if ! command_exists "$package"; then
            _a "Installing $package using $package_manager"
            # yes | $INSTALL_COMMAND $package 2>&1 | _log "installing $package using $package_manager"
            $INSTALL_COMMAND $package 2>&1
            _s "$package installed using $package_manager"
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
        git clone "$1" "$DOTFILES_PATH"
    else
        _e "git not installed"
    fi
}
read -rd '' default_config <<'EOF'
# This is a config file dotMaster uses to create links and install your dotfiles
# to know anout this config file visit "https://github.com/ashish-kus/dotfiles"

EOF

parse_ini() {
    local ini_file="$CONFIG_PATH"
    current_section=""
    while IFS= read -r line; do
        line=$(echo "$line" | sed -e 's/^[ \t]*//;s/[ \t]*$//')
        if [[ "$line" =~ ^\; ]] || [[ "$line" =~ ^\# ]] || [[ -z "$line" ]]; then
            continue
        fi
        if [[ "$line" =~ ^\[.*\]$ ]]; then
            current_section=$(echo "$line" | sed -e 's/^\[\(.*\)\]$/\1/')
        else
            key=$(echo "$line" | cut -d '=' -f 1)
            value=$(echo "$line" | cut -d '=' -f 2-)
            export "${current_section}_${key}"="$value"
        fi
    done < "$ini_file"
}

create_symlinks() {
  # directory_list=$(find "$DOTFILES_PATH" -mindepth 1 -type f -not -name 'install.sh')
  directory_list=$(find "$DOTFILES_PATH" -mindepth 1 -type f )
  _a "creating symbolic links"

  for entry in $directory_list; do
    # Trim "./" and extract the relative path
    modified_entry="${entry#./}"
    modified_entry="${modified_entry#*/}"

    # Obtain absolute paths
    absolute_path=$(realpath "${entry#./}")
    absolute_modified_entry="$HOME/$modified_entry"

    # Determine the target directory
    target_dir="$(dirname "$absolute_modified_entry")"

    # Check if the target directory exists, create it if not
    if [ ! -e "$target_dir" ]; then
      mkdir -p "$target_dir"
      _a "Created directory: $target_dir"
    fi


    # Uncomment the line below to create symbolic links
    ln -sf "$absolute_path" "$absolute_modified_entry"

    # Display the symbolic link creation information
    _s "$absolute_path >>>> $absolute_modified_entry"

  done
}

main() {
_w
_w "  ┌──────────────────────────────────────────┐"
_w "~ │ 🚀 Welcome to the ${green}DOTMASTER${normal} installer!  │ ~"
_w "  └──────────────────────────────────────────┘"
_w
_q 'Where do you want your dotfiles to be located? (default ~/.dotfiles)' "DOTFILES_PATH"
DOTFILES_PATH="${DOTFILES_PATH:-$HOME/.dotfiles}"
DOTFILES_PATH="$(eval echo "$DOTFILES_PATH")"
export DOTFILES_PATH="$DOTFILES_PATH" # path might contain variables or special characters that 
                                      # need to be expanded or interpreted correctly.                                      
CONFIG_PATH="$DOTFILES_PATH/config.ini"
setup_package_manager
# _a "Want to install all packages ?"
if ! command_exists "git";then
    install_packages "git"
fi 

DOTFILE_GIT_REPO=${DOTFILE_GIT_REPO:-${1}}
installing_repo "$DOTFILE_GIT_REPO"

# if [ ! -f $CONFIG_PATH ]; then
#     _e "config not found at $CONFIG_PATH"
#     _a "Creating config_ini at $CONFIG_PATH"
#     printf '%s\n' "$default_config" > "$CONFIG_PATH"
#     _s "config created successfully "
# else
#     _s "config found at $CONFIG_PATH"
# fi
# parse_ini $CONFIG_PATH
# echo $DOTFILE_GIT_REPO
# create_symlinks
}
main $@
