#!/bin/sh

unshare -fpmnc --mount-proc --keep-caps sh -c '

while read a b c ; do case "$b" in
/proc|/proc/*) ;;
*) mount -o bind,remount,ro "$b" ;;
esac ; done < /proc/mounts

mkrw () { mount -o rbind "$1" "$1" ; mount -o bind,remount,rw "$1" ; }

mkrw .

mount -t tmpfs none /tmp
mount -t tmpfs none /var/tmp
chmod 1777 /tmp /var/tmp

mkdir /tmp/dev
mount -t tmpfs none /tmp/dev
mkdir /tmp/dev/net
mkdir /tmp/dev/pts
ln -s pts/ptmx /tmp/dev/ptmx
for i in null zero full net/tun tty random urandom ; do
touch /tmp/dev/"$i"
mount -o bind "/dev/$i" "/tmp/dev/$i"
done
mount -o move /tmp/dev /dev

mount -t devpts none /dev/pts
chmod 666 /dev/pts/ptmx

exec unshare -w "$(pwd)" -mc "$@"
' - "$@"
