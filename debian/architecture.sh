#!/bin/sh
# Translate arch names into what factor expects.

case `dpkg-architecture -qDEB_HOST_ARCH` in
    powerpc|ppc)  echo 'ppc';;
    ?86|i?86)     echo 'x86';;
    amd64|x86_64) echo 'amd64';;
esac
