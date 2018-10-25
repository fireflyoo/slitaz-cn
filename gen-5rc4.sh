#!/bin/sh

URL="http://malibu.tuxfamily.net/slitaz"
ISO_URL="${URL}/iso/rolling/slitaz-rolling-core64.iso"
ISO=$(basename $ISO_URL)
ISO_PATH="/home/slitaz/5.0/distro"
PKG_MIRROR="${URL}/packages/5.0/"

tazlito clean-distro
mkdir -p $ISO_PATH
cd $ISO_PATH
if [ ! -e ../$ISO ]; then
    busybox wget -P .. $ISO_URL;
fi
if [ -e ../$ISO ]; then
    tazlito extract-distro ../$ISO;
fi
cat << EOF | chroot rootfs
echo hwclock -t >> /etc/init.d/local.sh
#echo ntpd -nq -p cn.ntp.org.cn >> /etc/init.d/local.sh
sed -i 's/ntpd//' /etc/rcS.conf
echo http://malibu.tuxfamily.net/slitaz/packages/5.0/ > /var/lib/tazpkg/mirror
rm /usr/share/locale/* -rf
gtk-query-immodules-2.0 --update-cache
udhcpc -i eth0
tazpkg recharge
yes | tazpkg remove locale-es
yes | tazpkg remove locale-de
yes | tazpkg remove locale-fr
yes | tazpkg remove locale-it
yes | tazpkg remove locale-pt
yes | tazpkg remove locale-pt_BR
yes | tazpkg remove locale-ru
tazpkg get-install locale-zh_CN
tazlocale zh_CN
tazpkg get-install fcitx
tazpkg clean-cache
sed -i  '4i\export XMODIFIERS="@im=fcitx"' /etc/skel/.xinitrc
sed -i '5i\export GTK_IM_MODULE=xim' /etc/skel/.xinitrc
sed -i '6i\fcitx &' /etc/skel/.xinitrc
sed -i 's/Monospace/DejaVu Sans Mono/' /etc/skel/.Xdefaults
EOF

tazlito gen-initiso
