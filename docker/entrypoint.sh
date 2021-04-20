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

echo "entrypoint"

exec $*

# top
# ping -i 10 127.0.0.1
# sleep infinity
# ping -i 30 bing.com -D
