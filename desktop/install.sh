#!/usr/bin/env bash

#bash -c "$(curl -L https://git.io/JORao)" @ tim TIM

# arg1: script name
# arg2: descripe name
install_desktop(){
    if ! [ -x "$(command -v docker)" ]; then
        echo 'Error: docker is not installed.' >&2
        exit 1
    fi
    [ -n ${HOME}/.local/bin/ ] && mkdir -p ${HOME}/.local/bin/
    [ -n ${HOME}/.local/share/icons/hicolor/256x256/apps ] && mkdir -p ${HOME}/.local/share/icons/hicolor/256x256/apps

    if ! [ -x "${HOME}/.local/bin/${1}.sh" ]; then
        echo "Install this script to ${HOME}/.local/bin/${1}.sh"

        curl -Ls -H "Cache-Control: no-cache" "https://raw.githubusercontent.com/ygcaicn/docker-deepin/main/desktop/$1.sh" -o "${HOME}/.local/bin/$1.sh"
        chmod +x "${HOME}/.local/bin/$1.sh"
        ln -i "${HOME}/.local/bin/$1.sh" "${HOME}/.local/bin/$1"
        cmd="${HOME}/.local/bin/$1.sh"
        curl -Ls -H "Cache-Control: no-cache" https://raw.githubusercontent.com/ygcaicn/docker-deepin/main/desktop/$1.png \
        -o ${HOME}/.local/share/icons/hicolor/256x256/apps/$1.png
        ls ${HOME}/.local/share/icons/hicolor/256x256/apps/$1.png
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
        echo "already installed at ${HOME}/.local/bin/$1.sh"
    fi
  return 0
}

install_desktop $*
