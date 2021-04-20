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
        -v $HOME:$HOME\
        -e XMODIFIERS=@im=fcitx \
        -e QT_IM_MODULE=fcitx \
        -e GTK_IM_MODULE=fcitx \
        -e DISPLAY=unix$DISPLAY \
        -e AUDIO_GID=`getent group audio | cut -d: -f3` \
        -e VIDEO_GID=`getent group video | cut -d: -f3` \
        -e GID=`id -g` \
        -e UID=`id -u` \
        jachin007/deepin \
        ping -i 30 bing.com -D
    fi
}


_install_in_container(){
    app=$1
    $(docker exec -t deepin dpkg -L $app > /dev/null 2>&1)
    if [[ $? -ne 0 ]]; then
        #install
        echo "Install to container..."
        docker exec -t deepin apt install -y ${app}
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
        [ -d $i ] && continue
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

    # copy run.sh to /home/deepin/run/${app}.sh
    cmd=`cat $to  | sed -n -r -e 's/^#Exec\="(.+)".*/\1/p'`

    sc=$(cat << EOF
set -e
[ ! -d /home/deepin/run ] && mkdir -p /home/deepin/run
cp $cmd /home/deepin/run/${app}.sh

EOF
)
    docker exec -u deepin -t deepin sh -c "$sc"

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
    # docker stop deepin
    docker rm deepin -f
}

run(){
    key="$1"
    case $key in
        deepin.com.thunderspeed|deepin.com.taobao.wangwang|deepin.com.taobao.aliclient.qianniu|deepin.com.qq.rtx2015|deepin.com.qq.office|deepin.com.qq.im.light|deepin.com.qq.im|deepin.com.qq.b.eim|deepin.com.qq.b.crm|deepin.com.gtja.fuyi|deepin.com.foxmail|deepin.com.cmbchina|deepin.com.baidu.pan|deepin.com.aaa-logo|deepin.com.95579.cjsc|deepin.cn.com.winrar|deepin.cn.360.yasuo|deepin.com.wechat|deepin.com.weixin.work|deepin.net.263.em|deepin.org.7-zip|deepin.org.foobar2000|deepin.net.cnki.cajviewer)
            app=$key
            cmd=`cat $HOME/.local/share/applications/$app.desktop  | sed -n -r -e 's/^#Exec\="(.+)".*/\1/p'`
            # cmd like: /opt/deepinwine/apps/Deepin-WeChat/run.sh
            # TODO: try run from if exists /home/deepin/run/${app}.sh
            if [ -x "$HOME/deepin/run/${app}.sh" ] ; then
                cmd="/home/deepin/run/${app}.sh"
            fi

            echo "exec command:"
            echo "docker exec -u deepin -d deepin $cmd"
            docker exec -u deepin -d deepin "$cmd"
        ;;
        *)
            echo "Unknown opt."
            exit 1
        ;;
    esac
}

help(){
    echo "Usage: docker-deepin COMMAND"
    echo ""
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
    echo "      deepin.com.thunderspeed deepin.com.taobao.wangwang deepin.com.taobao.aliclient.qianniu"
    echo "      deepin.com.qq.rtx2015 deepin.com.qq.office deepin.com.qq.im.light deepin.com.qq.im"
    echo "      deepin.com.qq.b.eim deepin.com.qq.b.crm deepin.com.gtja.fuyi deepin.com.foxmail"
    echo "      deepin.com.cmbchina deepin.com.baidu.pan deepin.com.aaa-logo deepin.com.95579.cjsc"
    echo "      deepin.cn.com.winrar deepin.cn.360.yasuo deepin.com.wechat deepin.com.weixin.work"
    echo "      deepin.net.263.em deepin.org.7-zip deepin.org.foobar2000 deepin.net.cnki.cajviewer"
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
