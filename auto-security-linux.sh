#!/bin/bash

set -e

######## General checks #########

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* This script must be executed with root privileges (sudo)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  exit 1
fi

########## Variables ############

# versioning
INSTALL_FIREWALL=false
CONFIGURE_FIREWALL=false
INSTALL_SSH=false
CONFIGURE_SSH=false

####### Visual functions ########

print_error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo ""
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}

print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}

##### User input functions ######

ask_firewall() {
  echo -e -n "* Do you want to automatically install and configure UFW (firewall)? (y/N): "
  read -r CONFIRM_UFW
  if [[ "$CONFIRM_UFW" =~ [Yy] ]]; then
    CONFIGURE_FIREWALL=true
    INSTALL_FIREWALL=true
    fi
    ;;
  esac
}
ask_ssh() {
  echo -e -n "* Do you want to automatically install and configure SSH? (y/N): "
  read -r CONFIRM_SSH
  if [[ "$CONFIRM_SSH" =~ [Yy] ]]; then
    CONFIGURE_SSH=true
    INSTALL_SSH=true
    fi
    ;;
  esac
}

##### Main installation functions #####
install_core_software() {
  echo "* Installing software.."
  sudo apt update && sudo apt upgrade
  sudo apt install git
  echo "* software installed!"
}

install_optional_software() {
  [ "$INSTALL_FIREWALL" == "true" ] && apt-get install -y ufw && firewall_ufw
  [ "$INSTALL_SSH" == "true" ] && apt-get install -y openssh-server openssh-client && configure_ssh
}

enable_services() {
  [ "$INSTALL_FIREWALL" == "true" ] && systemctl start ufw && systemctl enable ufw
  [ "$INSTALL_SSH" == "true" ] && systemctl start sshd && systemctl enable sshd
}

##### OTHER OS SPECIFIC FUNCTIONS #####
firewall_ufw() {

  echo -e "\n* Enabling Uncomplicated Firewall (UFW)"
  echo "* Opening port 22 (SSH)"

  # pointing to /dev/null silences the command output
  ufw allow ssh >/dev/null

  ufw --force enable
  ufw --force reload
  ufw status numbered | sed '/v6/d'
}

configure_ssh() {
  echo "* Configuring ssh .."
  rm -rf /etc/ssh/ssh_config

  cp config/ssh_config /etc/ssh/ssh_config
  systemctl restart sshd
  fi

  echo "SSH configured!"
}
##### MAIN FUNCTIONS #####
main() {
  print_brake 70
  echo "* Linux Security Automatic Configuration Script"
  echo "*"
  echo "* Copyright (C) 2022, Hydra Cloud LLC"
  echo "*"
  echo "* This script is associated with the official troy cyber team Chaparral Middle School Team 2! Which is the ONLY Team authorized to use this script!"
  print_brake 70

  # Ask if firewall and ssh is needed
  ask_firewall
  ask_ssh
  install_core_software
  install_optional_software
  enable_services

  # confirm installation
  echo -e -n "\n* Initial configuration completed. Continue with installation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    perform_install
  else
    # run welcome script again
    print_error "Installation aborted."
    exit 1
  fi
}

goodbye() {
  print_brake 62
  echo "* Linux security script is completed"
  echo "*"

  [ "$INSTALL_FIREWALL" == true ] && echo "* Your Firewall is installed, configured, and running!"
  [ "$ASSUME_SSH" == true ] && echo "* Your SSH Service is installed, configured, and running!"
  echo "* Thank you for using this script."
  print_brake 62
}

# run script
main
goodbye
