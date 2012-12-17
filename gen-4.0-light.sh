#!/bin/sh
tazpkg setup-undigest slitaz-cn http://slitaz-cn.googlecode.com/files/
tazpkg recharge
ISO_URL="http://mirror.slitaz.org/iso/4.0/flavors/slitaz-4.0-xorg-light.iso"
ISO=$(basename $ISO_URL)
ISO_PATH="/home/slitaz/4.0/distro"

tazlito clean-distro
mkdir -p $ISO_PATH
cd $ISO_PATH
busybox wget -P .. $ISO_URL
tazlito extract-distro ../$ISO
cd rootfs

rm ./usr/share/locale/* -rf
yes | tazpkg remove locale-es --root=.
yes | tazpkg remove locale-de --root=.
yes | tazpkg remove locale-fr --root=.
yes | tazpkg remove locale-it --root=.
yes | tazpkg remove locale-pt --root=.
tazpkg get-install b43-firmware --root=$(pwd) --forced
tazpkg get-install locale-zh_CN --root=$(pwd) --forced
tazpkg get-install fcitx-pinyin --root=$(pwd) --forced
tazpkg get-install fcitx-configtool --root=$(pwd) --forced
echo "fcitx &" >> ./etc/xdg/openbox/autostart.sh
echo LANG=zh_CN.UTF-8 > ./etc/locale.conf
echo us > ./etc/keymap.conf
echo Asia/Shanghai > ./etc/TZ
echo "hwclock -l -s" >> ./etc/init.d/local.sh
echo 'export XMODIFIERS="@im=fcitx"' >> ./etc/skel/.profile
tazlito gen-initiso
# 生成的ISO文件在/home/slitaz/4.0/distro/
