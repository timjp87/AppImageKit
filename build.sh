#!/bin/bash

#
# This script installs the required build-time dependencies
# and builds AppImage
#

HERE="$(dirname "$(readlink -f "${0}")")"

# Figure out whether we should use sudo
SUDO=''
if (( $EUID != 0 )); then
    SUDO='sudo'
fi

if [ -e /usr/bin/apt-get ] ; then
  $SUDO apt-get update
  $SUDO apt-get -y install libfuse-dev libglib2.0-dev cmake git libc6-dev binutils fuse

fi

if [ -e /usr/bin/yum ] ; then
  $SUDO yum -y install git cmake binutils fuse glibc-devel glib2-devel fuse-devel gcc zlib-devel libpng12
fi

# Install dependencies for Arch Linux
if [ -e /usr/bin/pacman ] ; then
  echo "Checking for existence of build dependencies."

  builddeps=('git' 'cmake' 'binutils' 'fuse' 'glibc' 'glib2' 'gcc' 'zlib')
  for i in "${builddeps[@]}" ; do
    pacman -Q "$i"
    if [ $? != 0 ] ; then
      sudo pacman -S "$i"
    else
      echo "$i is already installed."
    fi
  done
  
  echo "Checking for existence of dependencies from AUR."

  declare -a builddepsaur=('libpng12' 'ncurses5-compat-libs')
  for i in "${builddepsaur[@]}" ; do
    pacman -Q "$i"
    if [ $? != 0 ] ; then
      echo "Fetching $i from Arch Linux User Repo"
      git clone https://aur.archlinux.org/"$i".git && cd "$i" && \
      makepkg -si --skippgpcheck && \
      echo "Removing build directory." && \
      cd .. && rm -rf $i
    else
      echo "$i is already installed."
    fi
  done
fi

cd "${HERE}"
cmake .
make clean
make
cd -
