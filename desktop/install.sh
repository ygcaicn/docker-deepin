#!/usr/bin/env bash

DEEPIN="${HOME}/.local/bin/docker-deepin.sh"
ICON="${HOME}/.local/share/icons/hicolor/256x256/apps"
DESKTOP="${HOME}/.local/share/applications"
REPO="https://raw.githubusercontent.com/ygcaicn/docker-deepin/main"

#bash -c "$(curl -L https://git.io/JORao)" @ install deepin.com.qq.office deepin.com.wechat
#bash -c "$(curl -L https://git.io/JORao)" @ update

if ! [ -x "$(command -v docker)" ]; then
        echo 'Error: docker is not installed.' >&2
        exit 1
fi

download(){
	
    [ ! -d ${HOME}/.local/bin/ ] && mkdir -p ${HOME}/.local/bin/
    curl -Ls -H "Cache-Control: no-cache" "${REPO}/desktop/docker-deepin.sh" -o ${DEEPIN}
    chmod +x ${DEEPIN}
    ln -f ${DEEPIN} ${HOME}/.local/bin/docker-deepin
}

install(){
    key="$1"
    case $key in
        deepin.com.thunderspeed|deepin.com.taobao.wangwang|deepin.com.taobao.aliclient.qianniu|deepin.com.qq.rtx2015|deepin.com.qq.office|deepin.com.qq.im.light|deepin.com.qq.im|deepin.com.qq.b.eim|deepin.com.qq.b.crm|deepin.com.gtja.fuyi|deepin.com.foxmail|deepin.com.cmbchina|deepin.com.baidu.pan|deepin.com.aaa-logo|deepin.com.95579.cjsc|deepin.cn.com.winrar|deepin.cn.360.yasuo|deepin.com.wechat|deepin.com.weixin.work|deepin.net.263.em|deepin.org.7-zip|deepin.org.foobar2000|deepin.net.cnki.cajviewer)
            app=$key
            ${DEEPIN} install app
        ;;
        *)
            echo "Unknown opt."
            exit 1
        ;;
    esac
}

update(){
    rm -f ${DEEPIN}
    rm ${HOME}/.local/bin/docker-deepin
    download
}

key="$1"
case $key in
    --install|install)
        download
        ${DEEPIN} init
        a=(${@})
        for app in ${a[@]:1} ; do
            echo install $app
            install $app
        done
    ;;
    --update|update)
        update
        exit 0
    ;;
    *)
        echo "Unknown opt."
        exit 1
    ;;
esac
