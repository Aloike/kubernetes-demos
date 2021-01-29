#!/bin/bash
##  @see    https://linuxize.com/post/how-to-enable-ssh-on-ubuntu-18-04/

set -e


# 1 - Install the server
apt install -y	\
	openssh-server

# 2 - Enable the daemon at startup
systemctl enable ssh

# 3 - Update firewall rules
ufw allow ssh
