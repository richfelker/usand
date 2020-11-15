#!/bin/sh

unshare -fpmnc --mount-proc --keep-caps sh -c '

while read a b c ; do case "$b" in
/proc|/proc/*|/dev|/dev/*|/sys/*) ;;
*) mount -o bind,remount,ro "$b" ;;
esac ; done < /proc/mounts

mkrw () { mount -o rbind "$1" "$1" ; mount -o bind,remount,rw "$1" ; }

mkrw .

mount -t tmpfs none /tmp
mount -t tmpfs none /var/tmp
mount -t tmpfs none /var/run
chmod 1777 /tmp /var/tmp

mkdir /tmp/dev
mount -t tmpfs none /tmp/dev
mkdir /tmp/dev/net
mkdir /tmp/dev/pts
ln -s pts/ptmx /tmp/dev/ptmx
ln -s /proc/self/fd /tmp/dev/fd
ln -s fd/0 /tmp/dev/stdin
ln -s fd/1 /tmp/dev/stdout
ln -s fd/2 /tmp/dev/stderr
mkdir /tmp/dev/binds
mkdir /tmp/dev/binds/net
for i in null zero full net/tun tty random urandom ; do
touch /tmp/dev/binds/"$i"
mount -o bind "/dev/$i" "/tmp/dev/binds/$i"
ln -s /dev/binds/"$i" /tmp/dev/"$i"
done
mount -o move /tmp/dev /dev

mount -t devpts none /dev/pts
chmod 666 /dev/pts/ptmx

exec unshare -w "$(pwd)" -mc "$@"
' - "$@"
