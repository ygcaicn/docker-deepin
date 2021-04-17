# 创建容器

```
sudo xhost +
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
```

# 安装软件

容器中自带了WeChat和TIM。

```
docker exec -t deepin sh -c "apt update && apt install -y  deepin.com.thunderspeed"
```

## 软件包列表

```
deepin.com.thunderspeed
deepin.com.taobao.wangwang
deepin.com.taobao.aliclient.qianniu
deepin.com.qq.rtx2015
deepin.com.qq.office
deepin.com.qq.im.light
deepin.com.qq.im
deepin.com.qq.b.eim
deepin.com.qq.b.crm
deepin.com.gtja.fuyi
deepin.com.foxmail
deepin.com.cmbchina
deepin.com.baidu.pan
deepin.com.aaa-logo
deepin.com.95579.cjsc
deepin.cn.com.winrar
deepin.cn.360.yasuo
deepin.com.wechat
deepin.com.weixin.work
deepin.net.263.em
deepin.org.7-zip
deepin.org.foobar2000
deepin.net.cnki.cajviewer
```

## 查询软件包列表

```
docker exec -t deepin sh -c "apt update && apt search  'Deepin Wine'"
```

# 启动

```
# docker exec -d deepin tim.sh
docker exec -d deepin runuser -u deepin  /opt/deepinwine/apps/Deepin-TIM/run.sh
# docker exec -d deepin wechat.sh
docker exec -d deepin runuser -u deepin  /opt/deepinwine/apps/Deepin-WeChat/run.sh
```

## hidpi

```
f=$(mktemp).reg
cat <<-EOF > $f
REGEDIT4

[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Hardware Profiles\Current\Software\Fonts]
"LogPixels"=dword:00000060
EOF

docker cp $f deepin:$f
docker exec -it deepin  su deepin -c "WINEPREFIX=/home/deepin/.deepinwine/Deepin-WeChat deepin-wine regedit $f"
```

# 其它指令

```
#进入容器
docker exec -it deepin bash
#停止/启动容器
docker container stop deepin
docker container start deepin
#删除容器（出现问题时可以删除重建）
docker container rm deepin -f
#查看日志
docker logs -f deepin
```

# 感谢

<https://github.com/bestwu>


