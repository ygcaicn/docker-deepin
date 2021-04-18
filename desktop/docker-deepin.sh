#!/usr/bin/env bash

$(docker container start deepin > /dev/null 2>&1)
if [[ $? -ne 0 ]]; then
    docker container stop deepin > /dev/null 2>&1
    docker container rm deepin -f > /dev/null 2>&1
    docker run -d --name deepin \
    --device /dev/snd --ipc="host"\
    -v $HOME/deepin:/home/deepin \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e XMODIFIERS=@im=fcitx \
    -e QT_IM_MODULE=fcitx \
    -e GTK_IM_MODULE=fcitx \
    -e DISPLAY=unix$DISPLAY \
    -e AUDIO_GID=`getent group audio | cut -d: -f3` \
    -e VIDEO_GID=`getent group video | cut -d: -f3` \
    -e GID=`id -g` \
    -e UID=`id -u` \
    jachin007/deepin
fi

run(){
    key="$1"
    case $key in
        --tim|tim)
            docker exec -d deepin runuser -u deepin  /opt/deepinwine/apps/Deepin-TIM/run.sh
        ;;
        --wechat|wechat|WeChat)
            docker exec -d deepin runuser -u deepin  /opt/deepinwine/apps/Deepin-WeChat/run.sh
        ;;
        *)
            echo "Unknown opt."
            exit 1
        ;;
    esac
}

cmd="$1"
case $cmd in
    --run|run)
        run $2
    ;;
    *)
        echo "Unknown opt."
        exit 1
    ;;
esac
