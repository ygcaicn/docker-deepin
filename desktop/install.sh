#!/usr/bin/env bash

# arg1: script name
# arg2: descripe name
install(){
    if ! [ -x "$(command -v docker)" ]; then
        echo 'Error: docker is not installed.' >&2
        exit 1
    fi
    [ -n ~/.local/bin/ ] && mkdir -p ~/.local/bin/
    p=$(grep ~/.local/bin: ~/.bashrc)
    [ -n $p ] && echo "export PATH=\"$HOME/.local/bin:\$PATH\"" >> ~/.bashrc && source ~/.bashrc
    [ -n ~/.local/share/icons/hicolor/256x256/apps ] && mkdir -p ~/.local/share/icons/hicolor/256x256/apps


    if ! [ -x "~/.local/bin/${1}.sh" ]; then
        echo "Install this script to ~/.local/bin/${1}.sh" >&2
        curl -L -H "Cache-Control: no-cache" https://raw.githubusercontent.com/ygcaicn/docker-deepin/main/${1}.sh \
        -o "~/.local/bin/$1.sh"
        chmod +x "~/.local/bin/$1.sh"
        ln -i "~/.local/bin/$1.sh" "~/.local/bin/$1"
        cmd="/home/$(whoami)/.local/bin/$1.sh"
        curl -L -H "Cache-Control: no-cache" https://raw.githubusercontent.com/ygcaicn/ubuntu_qq/master/$1.png \
        -o ~/.local/share/icons/hicolor/256x256/apps/$1.png
        cat <<-EOF > /home/$(whoami)/.local/share/applications/$1.desktop
[Desktop Entry]
Categories=Network;InstantMessaging;
Exec=${cmd}
Icon=/home/$(whoami)/.local/share/icons/hicolor/256x256/apps/$1.png
Name=$2
NoDisplay=false
StartupNotify=true
Terminal=0
Type=Application
Name[en_US]=$2
EOF

    else
        echo "already installed at ~/.local/bin/$1.sh"
    fi
  return 0
}

install $*
