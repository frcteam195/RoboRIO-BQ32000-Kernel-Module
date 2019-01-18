#!/bin/sh

opkg update
opkg install coreutils i2c-tools ntpdate
mkdir bq
cd bq
wget https://raw.githubusercontent.com/frcteam195/RoboRIO-BQ32000-Kernel-Module/master/Makefile
wget https://raw.githubusercontent.com/frcteam195/RoboRIO-BQ32000-Kernel-Module/master/rtc-bq32k.c
mv Makefile Makefile_old
sed 's/ \+ /\t/g' Makefile_old > Makefile
rm -Rf Makefile_old
source /usr/local/natinst/tools/versioning_utils.sh
setup_versioning_env
versioning_call make
cp rtc-bq32k.ko /lib/modules/`uname -r`/kernel
depmod
echo bq32000 0x68 | tee /sys/class/i2c-adapter/i2c-2/new_device
ntpdate -s 0.us.pool.ntp.org
hwclock.util-linux --systohc --utc -f /dev/rtc0
echo '#!/bin/sh' > /etc/init.d/rtcenable.sh
echo 'echo bq32000 0x68 | tee /sys/class/i2c-adapter/i2c-2/new_device' >> /etc/init.d/rtcenable.sh
echo 'hwclock --hctosys -f /dev/rtc0' >> /etc/init.d/rtcenable.sh
chmod 775 /etc/init.d/rtcenable.sh
cd /etc/init.d/
sudo update-rc.d rtcenable.sh defaults
