#!/bin/sh
# loggy.sh.

date=`date +%F_%H-%M-%S`
dmesg -w > /cache/LineageOS-18.1_dmesg_${date}.txt
