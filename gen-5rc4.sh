#!/bin/sh

URL="http://malibu.tuxfamily.net/slitaz"
ISO_URL="${URL}/iso/rolling/slitaz-rolling-core.iso"
ISO=$(basename $ISO_URL)
ISO_PATH="/home/slitaz/5.0/distro"
PKG_MIRROR="${URL}/packages/5.0/"
IME_URL="https://github.com/fireflyoo/slitaz-cn/raw/master/yong-2.5.0.tazpkg"
IME=$(basename $IME_URL)
tazlito clean-distro
mkdir -p $ISO_PATH

[ ! -e $ISO ]&& wget -P . $ISO_URL
[ -e $ISO ] && tazlito extract-distro $ISO
echo "$URL/packages/5.0/" > $ISO_PATH/rootfs/var/lib/tazpkg/mirror
[ ! -e $IME ] && wget -P . $IME_URL
tazpkg install $IME --root=$ISO_PATH/rootfs --nodeps
tazpkg get wqy-microhei
tazpkg install wqy-microhei*.tazpkg --root=$ISO_PATH/rootfs --nodeps --local 
tazpkg get locale-zh_CN
tazpkg install locale-zh_CN*.tazpkg --root=$ISO_PATH/rootfs --nodeps --local
cat << EOF | chroot $ISO_PATH/rootfs
echo hwclock -t >> /etc/init.d/local.sh
echo "#ntpd -nq -p cn.ntp.org.cn" >> /etc/init.d/local.sh
sed -i 's/ntpd//' /etc/rcS.conf
rm /usr/share/locale/* -rf
#udhcpc -i eth0
yes | tazpkg remove locale-es
yes | tazpkg remove locale-de
yes | tazpkg remove locale-fr
yes | tazpkg remove locale-it
yes | tazpkg remove locale-pt
yes | tazpkg remove locale-pt_BR
yes | tazpkg remove locale-ru
tazlocale zh_CN
tazpkg clean-cache
cd /var/lib/tazpkg
rm packages.*
rm ID*
rm files*
rm *.txt
rm extra.list
gtk-query-immodules-2.0 --update-cache
#gtk-query-immodules-3.0 --update-cache
sed -i  '4i\export XMODIFIERS="@im=yong"' /etc/skel/.xinitrc
sed -i '5i\export GTK_IM_MODULE=yong' /etc/skel/.xinitrc
sed -i '6i\yong &' /etc/skel/.xinitrc
sed -i 's/Monospace/DejaVu Sans Mono/' /etc/skel/.Xdefaults
EOF

tazlito gen-initiso
