#!/usr/bin/env bash

# Programs returning != 0 will not cause script to exit
set +e

# Case insensitive string comparison
shopt -s nocaseglob
#shopt -s nocasematch

ECHO=echo
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

exit_script() {
    if [[ $FIND_MAKE_TARGET -eq true ]] ; then
		echo $MAKE_TARGET;
	fi
	exit $1
}

ensure_program_installed() {
    installed=0;
    for i in $* ;
    do
        $ECHO -n "Checking for $i..."
        test_program_installed $i
        if [[ $? -eq 0 ]]; then
            echo -n "not "
        else    
            installed=$(( $installed + 1 ))
        fi
        $ECHO "found!"
    done
    if [[ $installed -eq 0 ]] ; then
        $ECHO -n "Install "
        if [[ $# -eq 1 ]] ; then
            $ECHO -n $1
        else
            $ECHO -n "any of [ $* ]"
        fi
        $ECHO " and try again."
        exit_script 1;
    fi
}

check_ret() {
    RET=$?
    if [[ $RET -ne 0 ]] ; then
       $ECHO $1 failed
       exit_script 2
    fi
}

check_gcc_version() {
    $ECHO -n "Checking gcc version..."
    GCC_VERSION=`$CC --version`
    check_ret gcc
    if [[ $GCC_VERSION == *3.3.* ]] ; then
        $ECHO "You have a known buggy version of gcc (3.3)"
        $ECHO "Install gcc 3.4 or higher and try again."
        exit_script 3
    elif [[ $GCC_VERSION == *4.3.* ]] ; then
       MAKE_OPTS="$MAKE_OPTS SITE_CFLAGS=-fno-forward-propagate"
    fi
    $ECHO "ok."
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
    $ECHO -n "Checking for library $1..."
    $ECHO "int main(){return 0;}" > $GCC_TEST
    $CC $GCC_TEST -o $GCC_OUT -l $1
    if [[ $? -ne 0 ]] ; then
        $ECHO "not found!"
        $ECHO "Warning: library $1 not found."
        $ECHO "***Factor will compile NO_UI=1"
        NO_UI=1
    fi
    $DELETE -f $GCC_TEST
    check_ret $DELETE
    $DELETE -f $GCC_OUT
    check_ret $DELETE
    $ECHO "found."
}

check_X11_libraries() {
    check_library_exists GL
    check_library_exists X11
    check_library_exists pango-1.0
}

check_libraries() {
    case $OS in
            linux) check_X11_libraries;;
    esac
}

check_factor_exists() {
    if [[ -d "factor" ]] ; then
        $ECHO "A directory called 'factor' already exists."
        $ECHO "Rename or delete it and try again."
        exit_script 4
    fi
}

find_os() {
    if [[ -n $OS ]] ; then return; fi
    $ECHO "Finding OS..."
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
        SunOS) OS=solaris;;
    esac
}

find_architecture() {
    if [[ -n $ARCH ]] ; then return; fi
    $ECHO "Finding ARCH..."
    uname_m=`uname -m`
    check_ret uname
    case $uname_m in
       i386) ARCH=x86;;
       i686) ARCH=x86;;
       i86pc) ARCH=x86;;
       amd64) ARCH=x86;;
       ppc64) ARCH=ppc;;
       *86) ARCH=x86;;
       *86_64) ARCH=x86;;
       "Power Macintosh") ARCH=ppc;;
    esac
}

write_test_program() {
    echo "#include <stdio.h>" > $C_WORD.c
    echo "int main(){printf(\"%ld\", (long)(8*sizeof(void*))); return 0; }" >> $C_WORD.c
}

c_find_word_size() {
    $ECHO "Finding WORD..."
    C_WORD=factor-word-size
    write_test_program
    gcc -o $C_WORD $C_WORD.c
    WORD=$(./$C_WORD)
    check_ret $C_WORD
    $DELETE -f $C_WORD*
}

intel_macosx_word_size() {
    ensure_program_installed sysctl
    $ECHO -n "Testing if your Intel Mac supports 64bit binaries..."
    sysctl machdep.cpu.extfeatures | grep EM64T >/dev/null
    if [[ $? -eq 0 ]] ; then
        WORD=64
        $ECHO "yes!"
    else
        WORD=32
        $ECHO "no."
    fi
}

find_word_size() {
    if [[ -n $WORD ]] ; then return; fi
    if [[ $OS == macosx && $ARCH == x86 ]] ; then
        intel_macosx_word_size
    else
        c_find_word_size
    fi
}

set_factor_binary() {
    case $OS in
        winnt) FACTOR_BINARY=factor.com;;
        *) FACTOR_BINARY=factor;;
    esac
}

set_factor_library() {
    case $OS in
        winnt) FACTOR_LIBRARY=factor.dll;;
        macosx) FACTOR_LIBRARY=libfactor.dylib;;
        *) FACTOR_LIBRARY=libfactor.a;;
    esac
}

set_factor_image() {
    FACTOR_IMAGE=factor.image
}

echo_build_info() {
    $ECHO OS=$OS
    $ECHO ARCH=$ARCH
    $ECHO WORD=$WORD
    $ECHO FACTOR_BINARY=$FACTOR_BINARY
    $ECHO FACTOR_LIBRARY=$FACTOR_LIBRARY
    $ECHO FACTOR_IMAGE=$FACTOR_IMAGE
    $ECHO MAKE_TARGET=$MAKE_TARGET
    $ECHO BOOT_IMAGE=$BOOT_IMAGE
    $ECHO MAKE_IMAGE_TARGET=$MAKE_IMAGE_TARGET
    $ECHO GIT_PROTOCOL=$GIT_PROTOCOL
    $ECHO GIT_URL=$GIT_URL
    $ECHO DOWNLOADER=$DOWNLOADER
    $ECHO CC=$CC
    $ECHO MAKE=$MAKE
    $ECHO COPY=$COPY
    $ECHO DELETE=$DELETE
}

check_os_arch_word() {
    if ! [[ -n $OS && -n $ARCH && -n $WORD ]] ; then
        $ECHO "OS: $OS"
        $ECHO "ARCH: $ARCH"
        $ECHO "WORD: $WORD"
        $ECHO "OS, ARCH, or WORD is empty.  Please report this."

        echo $MAKE_TARGET
        exit_script 5
    fi
}

set_build_info() {
    check_os_arch_word
    if [[ $OS == macosx && $ARCH == ppc ]] ; then
        MAKE_IMAGE_TARGET=macosx-ppc
        MAKE_TARGET=macosx-ppc
    elif [[ $OS == linux && $ARCH == ppc ]] ; then
        MAKE_IMAGE_TARGET=linux-ppc
        MAKE_TARGET=linux-ppc
    elif [[ $OS == winnt && $ARCH == x86 && $WORD == 64 ]] ; then
        MAKE_IMAGE_TARGET=winnt-x86.64
        MAKE_TARGET=winnt-x86-64
    elif [[ $ARCH == x86 && $WORD == 64 ]] ; then
        MAKE_IMAGE_TARGET=unix-x86.64
        MAKE_TARGET=$OS-x86-64
    else
        MAKE_IMAGE_TARGET=$ARCH.$WORD
        MAKE_TARGET=$OS-$ARCH-$WORD
    fi
    BOOT_IMAGE=boot.$MAKE_IMAGE_TARGET.image
}

parse_build_info() {
    ensure_program_installed cut
    $ECHO "Parsing make target from command line: $1"
    OS=`echo $1 | cut -d '-' -f 1`
    ARCH=`echo $1 | cut -d '-' -f 2`
    WORD=`echo $1 | cut -d '-' -f 3`
    
    if [[ $OS == linux && $ARCH == ppc ]] ; then WORD=32; fi
    if [[ $OS == linux && $ARCH == arm ]] ; then WORD=32; fi
    if [[ $OS == macosx && $ARCH == ppc ]] ; then WORD=32; fi
    if [[ $OS == wince && $ARCH == arm ]] ; then WORD=32; fi
    
    $ECHO "OS=$OS"
    $ECHO "ARCH=$ARCH"
    $ECHO "WORD=$WORD"
}

find_build_info() {
    find_os
    find_architecture
    find_word_size
    set_factor_binary
    set_factor_library
    set_factor_image
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

set_copy() {
    case $OS in
        winnt) COPY=cp;;
        *) COPY=cp;;
    esac
}

set_delete() {
    case $OS in
        winnt) DELETE=rm;;
        *) DELETE=rm;;
    esac
}

backup_factor() {
    $ECHO "Backing up factor..."
    $COPY $FACTOR_BINARY $FACTOR_BINARY.bak
    $COPY $FACTOR_LIBRARY $FACTOR_LIBRARY.bak
    $COPY $BOOT_IMAGE $BOOT_IMAGE.bak
    $COPY $FACTOR_IMAGE $FACTOR_IMAGE.bak
    $ECHO "Done with backup."
}

check_makefile_exists() {
    if [[ ! -e "Makefile" ]] ; then
        echo ""
        echo "***Makefile not found***"
        echo "You are likely in the wrong directory."
        echo "Run this script from your factor directory:"
        echo "     ./build-support/factor.sh"
        exit_script 6
    fi
}

invoke_make() {
    check_makefile_exists
    $MAKE $MAKE_OPTS $*
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
    $DELETE checksums.txt* > /dev/null 2>&1
	# delete boot images with one or two characters after the dot
    $DELETE $BOOT_IMAGE.{?,??} > /dev/null 2>&1
    $DELETE temp/staging.*.image > /dev/null 2>&1
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
            $DELETE $BOOT_IMAGE > /dev/null 2>&1
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
    bootstrap
}


update() {
    get_config_info
    git_pull_factorcode
    backup_factor
    make_clean
    make_factor
}

update_bootstrap() {
    update_boot_images
    bootstrap
}

refresh_image() {
    ./$FACTOR_BINARY -script -e="USE: vocabs.loader USE: system refresh-all USE: memory save 0 exit"
    check_ret factor
}

make_boot_image() {
    ./$FACTOR_BINARY -script -e="\"$MAKE_IMAGE_TARGET\" USE: system USE: bootstrap.image make-image save 0 exit"
    check_ret factor

}

install_build_system_apt() {
    sudo apt-get --yes install libc6-dev libpango1.0-dev libx11-dev xorg-dev wget git-core git-doc rlwrap gcc make
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
    echo "usage: $0 install|install-x11|install-macosx|self-update|quick-update|update|bootstrap|dlls|net-bootstrap|make-target|report [optional-target]"
    echo "If you are behind a firewall, invoke as:"
    echo "env GIT_PROTOCOL=http $0 <command>"
    echo ""
    echo "Example for overriding the default target:"
    echo "    $0 update macosx-x86-32"
}

MAKE_TARGET=unknown

# -n is nonzero length, -z is zero length
if [[ -n "$2" ]] ; then
    parse_build_info $2
fi

set_copy
set_delete

case "$1" in
    install) install ;;
    install-x11) install_build_system_apt; install ;;
    install-macosx) install_build_system_port; install ;;
    self-update) update; make_boot_image; bootstrap;;
    quick-update) update; refresh_image ;;
    update) update; update_bootstrap ;;
    bootstrap) get_config_info; bootstrap ;;
    report) find_build_info ;;
    net-bootstrap) get_config_info; update_boot_images; bootstrap ;;
    make-target) FIND_MAKE_TARGET=true; ECHO=false; find_build_info; exit_script ;;
    *) usage ;;
esac
