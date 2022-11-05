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

DELETE_FLAG=false
UPDATE_FLAG=false

print_usage() {
  printf "Usage: ..."
}

while getopts 'du:' flag; do
  case "${flag}" in
    d) DELETE_FLAG=true ;;
    u) UPDATE_FLAG=true
       exit 1 ;;
  esac
done

update() {
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

delete() {
  echo -e -n "* What Software Do you want to Delete? (software name): "
  read -r SOFRWARE
  apt -y purge -autoremove $SOFTWARE
  apt -y autoremove
  apt -y autoclean
  apt -y update && sudo apt -y upgrade
}

goodbye() {
  echo "* Thank you for using this script."
}
main() {
  echo "Executing Functions..."
  if [ "$DELETE_FLAG" == true ]; then
    delete
    fi

  if [ "$UPDATE_FLAG" == true ]; then
    update
    fi
  echo "Done!"
}

# run script
main
goodbye
