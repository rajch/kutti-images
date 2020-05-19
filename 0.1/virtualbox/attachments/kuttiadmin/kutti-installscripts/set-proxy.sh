#!/bin/bash
set -e

if [ $(id -ur) -ne 0 ]; then
    echo $0 can only be run as root. Use sudo.
    exit 1
fi

if [ "$1" == "" ] ; then
    echo "Usage: $0 [OPTIONS] PROXYADDRESS NOPROXYADDRESSES"
    echo
    echo "Options:"
    echo "-r    Removes proxy settions. No need to specify further parameters,"
    echo
    echo "PROXYADDRESS should include the protocol and port number. E.g. http://proxy:8080"
    echo "NOPROXYADDRESSES should be comma-separated, without spaces. E.g. 192.168.125.4,192.168.125.5"
    exit 1
fi

if [ "$1" == "-r" ]; then
    echo "Removing user proxy..."
    unset http_proxy
    unset https_proxy
    unset no_proxy
    rm /etc/profile.d/rw-proxy.sh
    echo "Done."

    echo "Removing docker daemon proxy..."
    rm /etc/systemd/system/docker.service.d/rw-proxy.conf
    echo "Restarting docker daemon..."
    systemctl daemon-reload
    service docker restart
    echo "Done."

    exit 0
fi

# Setup user profile proxy
echo "Setting up user proxy..."
cat >/etc/profile.d/rw-proxy.sh <<ENDPROXY
export http_proxy=$1
export https_proxy=$1
export no_proxy=127.0.0.1,localhost,$2
ENDPROXY

source /etc/profile.d/rw-proxy.sh
echo "Done."

# Setup docker daemon proxy
echo "Setting up docker daemon proxy..."
if [ ! -d /etc/systemd/system/docker.service.d ]; then
    mkdir -p /etc/systemd/system/docker.service.d
fi

cat >>/etc/systemd/system/docker.service.d/rw-proxy.conf <<ENDDAEMON
[Service]
Environment="HTTP_PROXY=$1"
ENDDAEMON

echo "Restarting docker daemon..."
systemctl daemon-reload
service docker restart
echo "Done."

echo "Proxy files configured. Please log out and log in to complete."