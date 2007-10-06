#!/bin/bash -e

# Programs returning != 0 will not cause script to exit
set +e

# Case insensitive string comparison
shopt -s nocaseglob
shopt -s nocasematch

ensure_program_installed() {
        echo -n "Checking for $1..."
        result=`type -p $1`
        if ! [[ -n $result ]] ; then
                echo "not found!"
                echo "Install $1 and try again."
                exit 1
        fi
        echo "found!"
}

check_ret() {
        RET=$?
        if [[ $RET -ne 0 ]] ; then
                echo $1 failed
                exit 5
        fi
}

ensure_program_installed uname
ensure_program_installed git
ensure_program_installed wget
ensure_program_installed gcc
ensure_program_installed make

GCC_VERSION=`gcc --version`
if [[ $GCC_VERSION == *3.3.* ]] ; then
        echo "You have a known buggy version of gcc (3.3)"
        echo "Install gcc 3.4 or higher and try again."
        exit 1
fi

# OS
OS=
uname_s=`uname -s`
case $uname_s in
        CYGWIN_NT-5.2-WOW64) OS=windows-nt;;
        *CYGWIN_NT*) OS=windows-nt;;
        *CYGWIN*) OS=windows-nt;;
        *darwin*) OS=macosx;;
        *linux*) OS=linux;;
esac

# Architecture
ARCH=
uname_m=`uname -m`
case $uname_m in
        i386) ARCH=x86;;
        i686) ARCH=x86;;
        *86) ARCH=x86;;
        "Power Macintosh") ARCH=ppc;;
esac

WORD=
C_WORD=factor-word-size
# Word size
echo "#include <stdio.h>" > $C_WORD.c
echo "int main() { printf(\"%d\", 8*sizeof(long)); return 0; }" >> $C_WORD.c
gcc -o $C_WORD $C_WORD.c
WORD=$(./$C_WORD)
check_ret $C_WORD
rm -f $C_WORD*

case $OS in
        windows-nt) FACTOR_BINARY=factor-nt;;
        macosx) FACTOR_BINARY=./Factor.app/Contents/MacOS/factor;;
        *) FACTOR_BINARY=factor;;
esac

MAKE_TARGET=$OS-$ARCH-$WORD
BOOT_IMAGE=boot.$ARCH.$WORD.image

echo OS=$OS
echo ARCH=$ARCH
echo WORD=$WORD
echo FACTOR_BINARY=$FACTOR_BINARY
echo MAKE_TARGET=$MAKE_TARGET
echo BOOT_IMAGE=$BOOT_IMAGE

if ! [[ -n $OS && -n $ARCH && -n $WORD ]] ; then
        echo "OS, ARCH, or WORD is empty.  Please report this"
        exit 4
fi

echo "Downloading the git repository from factorcode.org..."
git clone git://factorcode.org/git/factor.git
check_ret git

cd factor
check_ret cd

make $MAKE_TARGET
check_ret make

echo "Deleting old images..."
rm $BOOT_IMAGE > /dev/null 2>&1
rm $BOOT_IMAGE.* > /dev/null 2>&1
wget http://factorcode.org/images/latest/$BOOT_IMAGE
check_ret wget

./$FACTOR_BINARY -i=$BOOT_IMAGE
