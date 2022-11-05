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
UPDATE=false
INSTALL_FTP=false
FTP_TYPE=1

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
}
ask_ssh() {
  echo -e -n "* Do you want to automatically install and configure SSH? (y/N): "
  read -r CONFIRM_SSH
  if [[ "$CONFIRM_SSH" =~ [Yy] ]]; then
    CONFIGURE_SSH=true
    INSTALL_SSH=true
    fi
}
ask_ftp() {
  echo -e -n "* Do you want to automatically install and configure FTP? (y/N): "
  read -r CONFIRM_FTP
  if [[ "$CONFIRM_FTP" =~ [Yy] ]]; then
    INSTALL_FTP=true
    fi
}
ask_ftp_server() {
  echo -e -n "* What type of FTP Server do you want to use? (1/2/3): "
  echo -e -n "* Server Types:"
  echo -e -n "* [1] Pure-FTPD"
  echo -e -n "* [2] VSFTPD"
  echo -e -n "* [3] Pro-FTPD"
  read -r FTP_TYPE
}
ask_updates() {
  echo -e -n "* Do you want to automatically update? (y/N): "
  read -r CONFIRM_UPDATE
  if [[ "$CONFIRM_UPDATE" =~ [Yy] ]]; then
    UPDATE=true
    fi
}

##### Main installation functions #####
install_core_software() {
  echo "* Installing software.."
  sudo apt -y update && sudo apt -y upgrade
  sudo apt -y install git
  echo "* software installed!"
}

install_optional_software() {
  [ "$INSTALL_FIREWALL" == "true" ] && apt install -y ufw && firewall_ufw
  [ "$INSTALL_SSH" == "true" ] && apt install -y openssh-server openssh-client && configure_ssh
  [ "$INSTALL_FTP" == "true" ] && install_ftp
}

update() {
  [ "$UPDATE" == "true" ] && update_software
}

enable_services() {
  [ "$INSTALL_FIREWALL" == "true" ] && systemctl start ufw && systemctl enable ufw
  [ "$INSTALL_SSH" == "true" ] && systemctl start ssh && systemctl enable ssh
  if [ "$INSTALL_FTP" == true ]; then
      [ "$FTP_TYPE" == "1" ] && systemctl restart pure-ftpd && systemctl enable pure-ftpd
      [ "$FTP_TYPE" == "2" ] && systemctl restart vsftpd && systemctl enable vsftpd
      [ "$FTP_TYPE" == "3" ] && systemctl restart proftpd && systemctl enable proftpd
      fi
}

##### OTHER OS SPECIFIC FUNCTIONS #####
firewall_ufw() {

  echo -e "\n* Enabling Uncomplicated Firewall (UFW)"
  echo "* Opening port 22 (SSH)"

  # pointing to /dev/null silences the command output
  ufw allow ssh >/dev/null

  [ "$INSTALL_FTP" == "true" ] && echo "* Opening port 21 (FTP)" && ufw allow ftp >/dev/null

  ufw --force enable
  ufw --force reload
  ufw status numbered | sed '/v6/d'
}

configure_ssh() {
  echo "* Configuring ssh .."
  rm -rf /etc/ssh/sshd_config

  cp config/sshd_config /etc/ssh/sshd_config
  systemctl restart sshd
  echo "SSH configured!"
}

install_ftp() {
  echo "* Installing FTP .."
  [ "$FTP_TYPE" == "1" ] && ftp_install_1
  [ "$FTP_TYPE" == "2" ] && ftp_install_2
  [ "$FTP_TYPE" == "3" ] && ftp_install_3
}

update_software() {
  echo "* Updating software.."
  apt -y update && apt -y upgrade
  apt-get -y install --only-upgrade bash
  apt-get -y dist-upgrade
  apt -y autoremove
  apt -y autoclean
  dpkg-reconfigure -plow unattended updates
  apt -y update && sudo apt -y upgrade
  echo "* software updated!"
}
##### INSTALLATION FUNCTIONS #####
ftp_install_1() {
  echo "* Installing Pure-FTPD.."
  apt -y update && apt -y upgrade
  apt -y install pure-ftpd
#  rm -rf /etc/pure-ftpd/conf
#  cp config/pure-ftpd-conf /etc/pure-ftpd/conf
  systemctl start pure-ftpd
  apt -y update && sudo apt -y upgrade
  echo "* Pure-FTPD Installed!"
}

ftp_install_2() {
  echo "* Installing VSFTPD.."
  apt -y update && sudo apt -y upgrade
  apt -y install vsftpd
#  rm -rf /etc/vsftpd.conf
#  cp config/vsftpd.conf /etc/vsftpd.conf
  systemctl start vsftpd
  apt -y update && sudo -y apt upgrade
  echo "* VSFTPD Installed!"
}

ftp_install_3() {
  echo "* Installing Pro-FTPD.."
  apt -y update && sudo apt -y upgrade
  apt -y install proftpd
#  rm -rf /etc/proftpd/proftpd.conf
#  cp config/proftpd.conf /etc/proftpd/proftpd.conf
  systemctl start proftpd
  apt -y update && sudo apt -y upgrade
  echo "* Pro-FTPD Installed!"
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
  ask_update
  ask_ftp
  if [ "$INSTALL_FTP" == true ]; then
    ask_ftp_type
    fi
  # confirm installation
  echo -e -n "\n* Initial configuration completed. Continue with installation? (y/N): "
  read -r CONFIRM
  if [[ "$CONFIRM" =~ [Yy] ]]; then
    install_core_software
    install_optional_software
    update
    enable_services
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
  [ "$UPDATE" == true ] && echo "* Your System Have been Updated! Your BASH Version is " && bash --version
  
  echo "* Thank you for using this script."
  print_brake 62
}

# run script
main
goodbye
