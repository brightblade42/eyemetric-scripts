#!/bin/bash
rm /usr/local/bin/docker-compose
apt purge docker-ce docker-ce-cli containerd.io docker-compose-plugin
apt purge nvidia-container-runtime
echo "uninstalled everything"

