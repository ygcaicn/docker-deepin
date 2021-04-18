#!/usr/bin/env bash

init(){
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
}


_install_in_container(){
    app=$1
    $(docker exec -t deepin dpkg -L $app > /dev/null 2>&1)
    if [[ $? -ne 0 ]]; then
        #install
        echo "Install to container..."
        docker exec -t deepin sh -c "apt install ${app}"
        return $?
    fi
    return 0
}

_install_desktop(){
    app=$1
    icons=$(docker exec -t deepin sh -c "IFS=$'\r\n' dpkg -L ${app} | grep -E /usr/share/icons/.+")
    IFS=$'\r\n'
    # install icons
    for i in $icons; do
        # id=`docker inspect -f   '{{.Id}}' deepin`
        from=$i
        [ -d $i ] && {
            continue
        }
        D="${HOME}/.local"
        to=${from/\/usr/$D}
        echo "deepin:$from -> $to"
        docker cp "deepin:$from" "$to"
        # convert svg to png
        [[ "${to##*.}" == "svg" ]] && {
            echo "convert to:"
            echo "${to%.*}.png"
            convert -density 1200 -background none -resize 512x512 "$to" "${to%.*}.png"
        }

    done

    # install desktop file
    IFS=$'\n'
    to=${HOME}/.local/share/applications/$app.desktop
    from=$(docker exec -t deepin sh -c "IFS=$'\n' dpkg -L ${app}" | sed -r -e 's/\r//g' | grep -E '\/usr\/share.+desktop')
    docker cp "deepin:$from" "$to"
    sed -i -r -e  's/^Exec/\#Exec/g' ${to}
    echo "Exec=\"$0\" run $app" >> ${to}
    chmod 755 ${to}
    echo "install desktop: ${to}"
    return 0
}

install(){
    key="$1"
    case $key in
        deepin.com.qq.office|deepin.com.wechat)
            app=$key
            _install_desktop $app
        ;;
        deepin.com.thunderspeed|deepin.com.taobao.wangwang|deepin.com.taobao.aliclient.qianniu|deepin.com.qq.rtx2015|deepin.com.qq.im.light|deepin.com.qq.im|deepin.com.qq.b.eim|deepin.com.qq.b.crm|deepin.com.gtja.fuyi|deepin.com.foxmail|deepin.com.cmbchina|deepin.com.baidu.pan|deepin.com.aaa-logo|deepin.com.95579.cjsc|deepin.cn.com.winrar|deepin.cn.360.yasuo|deepin.com.weixin.work|deepin.net.263.em|deepin.org.7-zip|deepin.org.foobar2000|deepin.net.cnki.cajviewer)
            app=$key
            _install_in_container $app
            if [[ $? -ne 0 ]]; then
                echo "Install error, please try:"
                echo "docker-deepin cleanup" 
                echo "docker-deepin init"
                exit 1
            else
                echo "Install OK!"
                _install_desktop $app
            fi
        ;;
        *)
            echo "Unknown opt."
            exit 1
        ;;
    esac
}

remove(){
    echo "remove"

}

# Stop and rm container
cleanup(){
    echo "clean up: stop&rm container"
    docker container stop deepin
    docker container rm deepin -f
}


run(){
    key="$1"
    case $key in
        deepin.com.thunderspeed|deepin.com.taobao.wangwang|deepin.com.taobao.aliclient.qianniu|deepin.com.qq.rtx2015|deepin.com.qq.office|deepin.com.qq.im.light|deepin.com.qq.im|deepin.com.qq.b.eim|deepin.com.qq.b.crm|deepin.com.gtja.fuyi|deepin.com.foxmail|deepin.com.cmbchina|deepin.com.baidu.pan|deepin.com.aaa-logo|deepin.com.95579.cjsc|deepin.cn.com.winrar|deepin.cn.360.yasuo|deepin.com.wechat|deepin.com.weixin.work|deepin.net.263.em|deepin.org.7-zip|deepin.org.foobar2000|deepin.net.cnki.cajviewer)
            app=$key
            cmd=`cat $HOME/.local/share/applications/$app.desktop  | sed -n -r -e 's/^#Exec\=(".+").*/\1/p'`

            echo "exec command:"
            echo "$SHELL -c \"docker exec -u deepin -d deepin $cmd\""
            $SHELL -c "docker exec -u deepin -d deepin $cmd"
        ;;
        *)
            echo "Unknown opt."
            exit 1
        ;;
    esac
}

help(){
    echo "Usage: docker-deepin COMMAND"
    echo "Commands:"
    echo ""
    echo "--init|init"
    echo "      Init a new container."
    echo "--install|install app"
    echo "      Install app to container and create Desktop file."
    echo "--run|run app"
    echo "--remove|remove app"
    echo "      Remove app(Desktop file)."
    echo "--cleanup|cleanup"
    echo "      Stop and remove current container."
    echo "--shell|shell|bash"
    echo "      Enter current container shell."
    echo "--logs|logs"
    echo "      Fetch the logs of a container"
    echo ""

    echo "app list: "
    echo "      deepin.com.thunderspeed|deepin.com.taobao.wangwang|deepin.com.taobao.aliclient.qianniu|deepin.com.qq.rtx2015|deepin.com.qq.office|deepin.com.qq.im.light|deepin.com.qq.im|deepin.com.qq.b.eim|deepin.com.qq.b.crm|deepin.com.gtja.fuyi|deepin.com.foxmail|deepin.com.cmbchina|deepin.com.baidu.pan|deepin.com.aaa-logo|deepin.com.95579.cjsc|deepin.cn.com.winrar|deepin.cn.360.yasuo|deepin.com.wechat|deepin.com.weixin.work|deepin.net.263.em|deepin.org.7-zip|deepin.org.foobar2000|deepin.net.cnki.cajviewer"
}

cmd="$1"
case $cmd in
    --run|run)
        run $2
    ;;
    --install|install)
        timeout 20 docker exec -t deepin sh -c "apt update"
        l=(${@})
        for app in ${l[@]:1} ; do
            echo "install $app"
            install $app
        done
    ;;
    --remove|remove)
        remove $2
    ;;
    --cleanup|cleanup)
        cleanup
    ;;
    --shell|shell|bash)
        docker exec -it deepin "bash"
    ;;
    --logs|logs)
        l=(${@})
        docker logs deepin ${l[@]:1}
    ;;
    --init|init)
        init
    ;;
    --help|help|*)
        echo "Unknown opt."
        help
        exit 1
    ;;
esac
