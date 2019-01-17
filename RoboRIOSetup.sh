#!/bin/sh

opkg update
opkg install coreutils i2c-tools ntp ntp-tickadj
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
/etc/init.d/ntpd stop
# before you do this step, you should set the date to as close to now as possible 
# date -s "Thu Jan  17 16:56:30 EST 2019"
ntpd -gq
/etc/init.d/ntpd start
hwclock.util-linux --systohc --utc -f /dev/rtc0
