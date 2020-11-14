#!/bin/sh

unshare -fpmnc --mount-proc --keep-caps sh -c '

while read a b c ; do case "$b" in
/proc|/proc/*) ;;
*) mount -o bind,remount,ro "$b" ;;
esac ; done < /proc/mounts

mkrw () { mount -o rbind "$1" "$1" ; mount -o bind,remount,rw "$1" ; }

mkrw .
for i in null zero full net/tun tty random urandom ; do mkrw "/dev/$i" ; done

mount -t tmpfs none /tmp
mount -t tmpfs none /var/tmp
chmod 1777 /tmp /var/tmp

mount -t devpts none /dev/pts
mount -o bind /dev/pts/ptmx /dev/ptmx
chmod 666 /dev/pts/ptmx

exec unshare -w "$(pwd)" -mc "$@"
' - "$@"
