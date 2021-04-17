#!/bin/bash
groupmod -o -g $AUDIO_GID audio
groupmod -o -g $VIDEO_GID video
if [ $GID != $(echo `id -g deepin`) ]; then
    groupmod -o -g $GID deepin
fi
if [ $UID != $(echo `id -u deepin`) ]; then
    usermod -o -u $UID deepin
fi

su deepin <<EOF
    mkdir -p ~/.deepinwine
EOF

apt-get update
apt-get upgrade
apt-get -y autoremove --purge && apt-get autoclean -y && apt-get clean -y && \
find /var/lib/apt/lists -type f -delete && \
find /var/cache -type f -delete && \
find /var/log -type f -delete && \
find /usr/share/doc -type f -delete && \
find /usr/share/man -type f -delete

sleep infinity
