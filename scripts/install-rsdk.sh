#!/bin/bash

set -e

if [[ -n $DISTRO_MIRROR ]];
then
  sudo sed -i -e "s|http://archive.ubuntu.com|$DISTRO_MIRROR|g" \
    -e "s|http://security.ubuntu.com|$DISTRO_MIRROR|g" /etc/apt/sources.list
fi

sudo apt-get update && sudo apt-get install -y /opt/rsdk.deb /opt/librtui.deb

exec /bin/bash
