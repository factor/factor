#!/usr/bin/env bash

# Programs returning != 0 will not cause script to exit
set +e

# Case insensitive string comparison
shopt -s nocaseglob
#shopt -s nocasematch

OS=
ARCH=
WORD=
NO_UI=
GIT_PROTOCOL=${GIT_PROTOCOL:="git"}
GIT_URL=${GIT_URL:=$GIT_PROTOCOL"://factorcode.org/git/factor.git"}

test_program_installed() {
    if ! [[ -n `type -p $1` ]] ; then
        return 0;
    fi
    return 1;
}

ensure_program_installed() {
    installed=0;
    for i in $* ;
    do
        echo -n "Checking for $i..."
        test_program_installed $i
        if [[ $? -eq 0 ]]; then
            echo -n "not "
        else    
            installed=$(( $installed + 1 ))
        fi
        echo "found!"
    done
    if [[ $installed -eq 0 ]] ; then
        echo -n "Install "
        if [[ $# -eq 1 ]] ; then
            echo -n $1
        else
            echo -n "any of [ $* ]"
        fi
        echo " and try again."
        exit 1
    fi
}

check_ret() {
    RET=$?
    if [[ $RET -ne 0 ]] ; then
       echo $1 failed
       exit 2
    fi
}

check_gcc_version() {
    echo -n "Checking gcc version..."
    GCC_VERSION=`$CC --version`
    check_ret gcc
    if [[ $GCC_VERSION == *3.3.* ]] ; then
        echo "bad!"
        echo "You have a known buggy version of gcc (3.3)"
        echo "Install gcc 3.4 or higher and try again."
        exit 3
    fi
    echo "ok."
}

set_downloader() {
    test_program_installed wget curl
    if [[ $? -ne 0 ]] ; then
        DOWNLOADER=wget
    else
        DOWNLOADER="curl -O"
    fi
}

set_md5sum() {
    test_program_installed md5sum
    if [[ $? -ne 0 ]] ; then
        MD5SUM=md5sum
    else
        MD5SUM="md5 -r"
    fi
}

set_gcc() {
    case $OS in
        openbsd) ensure_program_installed egcc; CC=egcc;;
	netbsd) if [[ $WORD -eq 64 ]] ; then
			CC=/usr/pkg/gcc34/bin/gcc
		fi ;;
        *) CC=gcc;;
    esac
}

set_make() {
    case $OS in
        netbsd) MAKE='gmake';;
        freebsd) MAKE='gmake';;
        openbsd) MAKE='gmake';;
        dragonflybsd) MAKE='gmake';;
        *) MAKE='make';;
    esac
    if ! [[ $MAKE -eq 'gmake' ]] ; then
    	ensure_program_installed gmake
    fi
}

check_installed_programs() {
    ensure_program_installed chmod
    ensure_program_installed uname
    ensure_program_installed git
    ensure_program_installed wget curl
    ensure_program_installed gcc
    ensure_program_installed make gmake
    ensure_program_installed md5sum md5
    ensure_program_installed cut
    check_gcc_version
}

check_library_exists() {
    GCC_TEST=factor-library-test.c
    GCC_OUT=factor-library-test.out
    echo -n "Checking for library $1..."
    echo "int main(){return 0;}" > $GCC_TEST
    $CC $GCC_TEST -o $GCC_OUT -l $1
    if [[ $? -ne 0 ]] ; then
        echo "not found!"
        echo "Warning: library $1 not found."
        echo "***Factor will compile NO_UI=1"
        NO_UI=1
    fi
    rm -f $GCC_TEST
    check_ret rm
    rm -f $GCC_OUT
    check_ret rm
    echo "found."
}

check_X11_libraries() {
    check_library_exists freetype
    check_library_exists GLU
    check_library_exists GL
    check_library_exists X11
}

check_libraries() {
    case $OS in
            linux) check_X11_libraries;;
    esac
}

check_factor_exists() {
    if [[ -d "factor" ]] ; then
        echo "A directory called 'factor' already exists."
        echo "Rename or delete it and try again."
        exit 4
    fi
}

find_os() {
    echo "Finding OS..."
    uname_s=`uname -s`
    check_ret uname
    case $uname_s in
        CYGWIN_NT-5.2-WOW64) OS=winnt;;
        *CYGWIN_NT*) OS=winnt;;
        *CYGWIN*) OS=winnt;;
        *darwin*) OS=macosx;;
        *Darwin*) OS=macosx;;
        *linux*) OS=linux;;
        *Linux*) OS=linux;;
        *NetBSD*) OS=netbsd;;
        *FreeBSD*) OS=freebsd;;
        *OpenBSD*) OS=openbsd;;
        *DragonFly*) OS=dragonflybsd;;
    esac
}

find_architecture() {
    echo "Finding ARCH..."
    uname_m=`uname -m`
    check_ret uname
    case $uname_m in
       i386) ARCH=x86;;
       i686) ARCH=x86;;
       amd64) ARCH=x86;;
       *86) ARCH=x86;;
       *86_64) ARCH=x86;;
       "Power Macintosh") ARCH=ppc;;
    esac
}

write_test_program() {
    echo "#include <stdio.h>" > $C_WORD.c
    echo "int main(){printf(\"%d\", 8*sizeof(void*)); return 0; }" >> $C_WORD.c
}

find_word_size() {
    echo "Finding WORD..."
    C_WORD=factor-word-size
    write_test_program
    gcc -o $C_WORD $C_WORD.c
    WORD=$(./$C_WORD)
    check_ret $C_WORD
    rm -f $C_WORD*
}

set_factor_binary() {
    case $OS in
        # winnt) FACTOR_BINARY=factor-nt;;
        # macosx) FACTOR_BINARY=./Factor.app/Contents/MacOS/factor;;
        *) FACTOR_BINARY=factor;;
    esac
}

echo_build_info() {
    echo OS=$OS
    echo ARCH=$ARCH
    echo WORD=$WORD
    echo FACTOR_BINARY=$FACTOR_BINARY
    echo MAKE_TARGET=$MAKE_TARGET
    echo BOOT_IMAGE=$BOOT_IMAGE
    echo MAKE_IMAGE_TARGET=$MAKE_IMAGE_TARGET
    echo GIT_PROTOCOL=$GIT_PROTOCOL
    echo GIT_URL=$GIT_URL
    echo DOWNLOADER=$DOWNLOADER
    echo CC=$CC
    echo MAKE=$MAKE
}

set_build_info() {
    if ! [[ -n $OS && -n $ARCH && -n $WORD ]] ; then
        echo "OS: $OS"
        echo "ARCH: $ARCH"
        echo "WORD: $WORD"
        echo "OS, ARCH, or WORD is empty.  Please report this"
        exit 5
    fi

    MAKE_TARGET=$OS-$ARCH-$WORD
    MAKE_IMAGE_TARGET=$ARCH.$WORD
    BOOT_IMAGE=boot.$ARCH.$WORD.image
    if [[ $OS == macosx && $ARCH == ppc ]] ; then
        MAKE_IMAGE_TARGET=$OS-$ARCH
        MAKE_TARGET=$OS-$ARCH
        BOOT_IMAGE=boot.macosx-ppc.image
    fi
    if [[ $OS == linux && $ARCH == ppc ]] ; then
        MAKE_IMAGE_TARGET=$OS-$ARCH
        MAKE_TARGET=$OS-$ARCH
        BOOT_IMAGE=boot.linux-ppc.image
    fi
}

find_build_info() {
    find_os
    find_architecture
    find_word_size
    set_factor_binary
    set_build_info
	set_downloader
	set_gcc
	set_make
    echo_build_info
}

invoke_git() {
    git $*
    check_ret git
}

git_clone() {
    echo "Downloading the git repository from factorcode.org..."
    invoke_git clone $GIT_URL
}

git_pull_factorcode() {
    echo "Updating the git repository from factorcode.org..."
    invoke_git pull $GIT_URL master
}

cd_factor() {
    cd factor
    check_ret cd
}

invoke_make() {
   $MAKE $*
   check_ret $MAKE
}

make_clean() {
    invoke_make clean
}

make_factor() {
    invoke_make NO_UI=$NO_UI $MAKE_TARGET -j5
}

update_boot_images() {
    echo "Deleting old images..."
    rm checksums.txt* > /dev/null 2>&1
    rm $BOOT_IMAGE.* > /dev/null 2>&1
    rm staging.*.image > /dev/null 2>&1
    if [[ -f $BOOT_IMAGE ]] ; then
        get_url http://factorcode.org/images/latest/checksums.txt
        factorcode_md5=`cat checksums.txt|grep $BOOT_IMAGE|cut -f2 -d' '`;
        set_md5sum
        case $OS in
             netbsd) disk_md5=`md5 $BOOT_IMAGE | cut -f4 -d' '`;;
             *) disk_md5=`$MD5SUM $BOOT_IMAGE|cut -f1 -d' '` ;;
        esac
        echo "Factorcode md5: $factorcode_md5";
        echo "Disk md5: $disk_md5";
        if [[ "$factorcode_md5" == "$disk_md5" ]] ; then
            echo "Your disk boot image matches the one on factorcode.org."
        else
            rm $BOOT_IMAGE > /dev/null 2>&1
            get_boot_image;
        fi
    else
        get_boot_image
    fi
}

get_boot_image() {
    echo "Downloading boot image $BOOT_IMAGE."
    get_url http://factorcode.org/images/latest/$BOOT_IMAGE
}

get_url() {
    if [[ $DOWNLOADER -eq "" ]] ; then
        set_downloader;
    fi
    echo $DOWNLOADER $1 ;
    $DOWNLOADER $1
    check_ret $DOWNLOADER
}

maybe_download_dlls() {
    if [[ $OS == winnt ]] ; then
        get_url http://factorcode.org/dlls/freetype6.dll
        get_url http://factorcode.org/dlls/zlib1.dll
        get_url http://factorcode.org/dlls/OpenAL32.dll
        get_url http://factorcode.org/dlls/alut.dll
        get_url http://factorcode.org/dlls/ogg.dll
        get_url http://factorcode.org/dlls/theora.dll
        get_url http://factorcode.org/dlls/vorbis.dll
        get_url http://factorcode.org/dlls/sqlite3.dll
        chmod 777 *.dll
        check_ret chmod
    fi
}

get_config_info() {
    find_build_info
    check_installed_programs
    check_libraries
}

bootstrap() {
    ./$FACTOR_BINARY -i=$BOOT_IMAGE
}

install() {
    check_factor_exists
    get_config_info
    git_clone
    cd_factor
    make_factor
    get_boot_image
    maybe_download_dlls
    bootstrap
}


update() {
    get_config_info
    git_pull_factorcode
    make_clean
    make_factor
}

update_bootstrap() {
    update_boot_images
    bootstrap
}

refresh_image() {
    ./$FACTOR_BINARY -script -e="USE: vocabs.loader refresh-all USE: memory save 0 USE: system exit"
    check_ret factor
}

make_boot_image() {
    ./$FACTOR_BINARY -script -e="\"$MAKE_IMAGE_TARGET\" USE: bootstrap.image make-image save 0 USE: system exit"
    check_ret factor

}

install_build_system_apt() {
    ensure_program_installed yes
    yes | sudo apt-get install sudo libc6-dev libfreetype6-dev libx11-dev xorg-dev glutg3-dev wget git-core git-doc rlwrap gcc make
    check_ret sudo
}

install_build_system_port() {
    test_program_installed git
    if [[ $? -ne 1 ]] ; then
    	ensure_program_installed yes
		echo "git not found."
		echo "This script requires either git-core or port."
		echo "If it fails, install git-core or port and try again."
    	ensure_program_installed port
		echo "Installing git-core with port...this will take awhile."
    	yes | sudo port install git-core
    fi
}

usage() {
    echo "usage: $0 install|install-x11|install-macosx|self-update|quick-update|update|bootstrap|net-bootstrap"
    echo "If you are behind a firewall, invoke as:"
    echo "env GIT_PROTOCOL=http $0 <command>"
}

case "$1" in
    install) install ;;
    install-x11) install_build_system_apt; install ;;
    install-macosx) install_build_system_port; install ;;
    self-update) update; make_boot_image; bootstrap;;
    quick-update) update; refresh_image ;;
    update) update; update_bootstrap ;;
    bootstrap) get_config_info; bootstrap ;;
    net-bootstrap) get_config_info; update_boot_images; bootstrap ;;
    *) usage ;;
esac
