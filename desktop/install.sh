#!/usr/bin/env bash

DEEPIN="${HOME}/.local/bin/docker-deepin.sh"
ICON="${HOME}/.local/share/icons/hicolor/256x256/apps"
DESKTOP="${HOME}/.local/share/applications"
REPO="https://raw.githubusercontent.com/ygcaicn/docker-deepin/main"

#bash -c "$(curl -L https://git.io/JORao)" @ tim TIM

# arg1: script name
# arg2: descripe name
# arg3: img url
# arg4: cmd
install_desktop(){
    if ! [ -e "${DESKTOP}/${1}.desktop" ]; then
        cmd="$4"
        curl -Ls -H "Cache-Control: no-cache" "$3" -o ${ICON}/${1}.png
        cat <<-EOF > "${DESKTOP}/${1}.desktop"
[Desktop Entry]
Categories=Network;InstantMessaging;
Exec=${cmd}
Icon=${ICON}/${1}.png
Name=$2
NoDisplay=false
StartupNotify=true
Terminal=0
Type=Application
Name[en_US]=$2
EOF
    else
        echo "already installed at "${DESKTOP}/${1}.desktop"
    fi
  return 0
}

# arg1: desktop path
# arg2: img path
remove_desktop(){
    for f in $[@];do
        rm -f "$f"
    done
}

install(){
    key="$1"
    case $key in
        --tim|tim)
            cmd="${DEEPIN} run tim"
            img="${REPO}/desktop/icons/tim.png"
            install_desktop deepin_tim TIM "$img" "$cmd"
        ;;
        --WeChat|WeChat)
            cmd="${DEEPIN} run WeChat"
            img="${REPO}/desktop/icons/wechat.png"
            install_desktop deepin_wechat WeChat "$img" "$cmd"
        ;;
        *)
        echo "Unknown opt."
        exit 1
        ;;
    esac
    
    
}

remove(){
    remove_desktop "${DEEPIN}" "${HOME}/.local/bin/docker-deepin"\
                    "${REPO}/desktop/icons/wechat.png" "${REPO}/desktop/icons/tim.png"\
                     ${DESKTOP}/deepin_wechat.desktop ${DESKTOP}/deepin_tim.desktop
}

key="$1"

case $key in
    --install|install)
    if ! [ -x "$(command -v docker)" ]; then
            echo 'Error: docker is not installed.' >&2
            exit 1
    fi
    [ -n ${HOME}/.local/bin/ ] && mkdir -p ${HOME}/.local/bin/
    curl -Ls -H "Cache-Control: no-cache" "${REPO}/desktop/docker-deepin.sh" -o ${DEEPIN}
    chmod +x ${DEEPIN}
    ln -i ${DEEPIN} ${HOME}/.local/bin/docker-deepin
    [ -n ${ICON} ] && mkdir -p ${ICON}

    for app in ${$[@]:1}; do
        install $app
    done
    ;;
    --remove|remove)
    remove
    ;;
esac
