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
NO_UI=${NO_UI-}
GIT_PROTOCOL=${GIT_PROTOCOL:="git"}
GIT_URL=${GIT_URL:=$GIT_PROTOCOL"://factorcode.org/git/factor.git"}
SCRIPT_ARGS="$*"

test_program_installed() {
    if ! [[ -n `type -p $1` ]] ; then
        return 0;
    fi
    return 1;
}

exit_script() {
    if [[ $FIND_MAKE_TARGET = true ]] ; then
        # Must be echo not $ECHO
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
            $ECHO -n "not "
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
        if [[ $OS -eq macosx ]] ; then
            $ECHO "If you have Xcode 4.3 or higher installed, you must install the"
            $ECHO "Command Line Tools from Xcode Preferences > Downloads in order"
            $ECHO "to build Factor."
        fi
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

set_downloader() {
    test_program_installed wget curl
    if [[ $? -ne 0 ]] ; then
        DOWNLOADER=wget
    else
        DOWNLOADER="curl -f -O"
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
        macosx)
            xcode_major=`xcodebuild -version | sed -E -ne 's/^Xcode ([0-9]+).*$/\1/p'`
            if [[ $xcode_major -ge 4 ]]; then
                CC=clang
                CPP=clang++
            else
                CC=gcc
                CPP=g++
            fi
        ;;
        *)
            CC=gcc
            CPP=g++
        ;;
    esac
}

set_make() {
    MAKE='make'
}

check_git_branch() {
    BRANCH=`git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,'`
    if [ "$BRANCH" != "master" ] ; then
        $ECHO "git branch is $BRANCH, not master"
        exit_script 3
    fi
}

check_installed_programs() {
    ensure_program_installed chmod
    ensure_program_installed uname
    ensure_program_installed git
    ensure_program_installed wget curl
    ensure_program_installed clang gcc
    ensure_program_installed clang++ g++ cl
    ensure_program_installed make gmake
    ensure_program_installed md5sum md5
    ensure_program_installed cut
}

check_library_exists() {
    GCC_TEST=factor-library-test.c
    GCC_OUT=factor-library-test.out
    $ECHO -n "Checking for library $1..."
    $ECHO "int main(){return 0;}" > $GCC_TEST
    $CC $GCC_TEST -o $GCC_OUT -l $1 2>&-
    if [[ $? -ne 0 ]] ; then
        $ECHO "not found!"
        $ECHO "***Factor will compile NO_UI=1"
        NO_UI=1
    else
        $ECHO "found."
    fi
    $DELETE -f $GCC_TEST
    check_ret $DELETE
    $DELETE -f $GCC_OUT
    check_ret $DELETE
}

check_X11_libraries() {
    if [ -z "$NO_UI" ]; then
        check_library_exists GL
        check_library_exists X11
        check_library_exists pango-1.0
    fi
}

check_gtk_libraries() {
    if [ -z "$NO_UI" ]; then
        check_library_exists gobject-2.0
        check_library_exists gtk-x11-2.0
        check_library_exists gdk-x11-2.0
        check_library_exists gdk_pixbuf-2.0
        check_library_exists gtkglext-x11-1.0
        check_library_exists atk-1.0
        check_library_exists gio-2.0
        check_library_exists gdkglext-x11-1.0
        check_library_exists pango-1.0
    fi
}


check_libraries() {
    case $OS in
            linux) check_X11_libraries
                   check_gtk_libraries;;
            unix) check_gtk_libraries;;
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
        CYGWIN_NT-5.2-WOW64) OS=windows;;
        *CYGWIN_NT*) OS=windows;;
        *CYGWIN*) OS=windows;;
        MINGW32*) OS=windows;;
        *darwin*) OS=macosx;;
        *Darwin*) OS=macosx;;
        *linux*) OS=linux;;
        *Linux*) OS=linux;;
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
    #! Must be 'echo'
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
        windows) FACTOR_BINARY=factor.com;;
        *) FACTOR_BINARY=factor;;
    esac
}

set_factor_library() {
    case $OS in
        windows) FACTOR_LIBRARY=factor.dll;;
        macosx) FACTOR_LIBRARY=libfactor.dylib;;
        *) FACTOR_LIBRARY=libfactor.a;;
    esac
}

set_factor_image() {
    FACTOR_IMAGE=factor.image
    FACTOR_IMAGE_FRESH=factor.image.fresh
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

        $ECHO $MAKE_TARGET
        exit_script 5
    fi
}

set_build_info() {
    check_os_arch_word
    if [[ $OS == linux && $ARCH == ppc ]] ; then
        MAKE_IMAGE_TARGET=linux-ppc.32
        MAKE_TARGET=linux-ppc-32
    elif [[ $OS == windows && $ARCH == x86 && $WORD == 64 ]] ; then
        MAKE_IMAGE_TARGET=windows-x86.64
        MAKE_TARGET=windows-x86-64
    elif [[ $OS == windows && $ARCH == x86 && $WORD == 32 ]] ; then
        MAKE_IMAGE_TARGET=windows-x86.32
        MAKE_TARGET=windows-x86-32
    elif [[ $ARCH == x86 && $WORD == 64 ]] ; then
        MAKE_IMAGE_TARGET=unix-x86.64
        MAKE_TARGET=$OS-x86-64
    elif [[ $ARCH == x86 && $WORD == 32 ]] ; then
        MAKE_IMAGE_TARGET=unix-x86.32
        MAKE_TARGET=$OS-x86-32
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
    $ECHO "Downloading the git repository from factorcode.org..."
    invoke_git clone $GIT_URL
}

update_script_name() {
    $ECHO `dirname $0`/_update.sh
}

update_script() {
    update_script=`update_script_name`
    bash_path=`which bash`
    $ECHO "#!$bash_path" >"$update_script"
    $ECHO "git pull \"$GIT_URL\" master" >>"$update_script"
    $ECHO "if [[ \$? -eq 0 ]]; then exec \"$0\" $SCRIPT_ARGS; else echo \"git pull failed\"; exit 2; fi" \
        >>"$update_script"
    $ECHO "exit 0" >>"$update_script"

    chmod 755 "$update_script"
    exec "$update_script"
}

update_script_changed() {
    invoke_git diff --stat `invoke_git merge-base HEAD FETCH_HEAD` FETCH_HEAD | grep 'build-support.factor\.sh' >/dev/null 
}

git_fetch_factorcode() {
    $ECHO "Fetching the git repository from factorcode.org..."

    rm -f `update_script_name`
    invoke_git fetch "$GIT_URL" master

    if update_script_changed; then
        $ECHO "Updating and restarting the factor.sh script..."
        update_script
    else
        $ECHO "Updating the working tree..."
        invoke_git pull "$GIT_URL" master
    fi
}

cd_factor() {
    cd factor
    check_ret cd
}

set_copy() {
    case $OS in
        windows) COPY=cp;;
        *) COPY=cp;;
    esac
}

set_delete() {
    case $OS in
        windows) DELETE=rm;;
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
    if [[ ! -e "GNUmakefile" ]] ; then
        $ECHO ""
        $ECHO "***GNUmakefile not found***"
        $ECHO "You are likely in the wrong directory."
        $ECHO "Run this script from your factor directory:"
        $ECHO "     ./build-support/factor.sh"
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

make_clean_factor() {
    make_clean
    make_factor
}

update_boot_images() {
    $ECHO "Deleting old images..."
    $DELETE checksums.txt* > /dev/null 2>&1
    # delete boot images with one or two characters after the dot
    $DELETE $BOOT_IMAGE.{?,??} > /dev/null 2>&1
    $DELETE temp/staging.*.image > /dev/null 2>&1
    if [[ -f $BOOT_IMAGE ]] ; then
        get_url http://downloads.factorcode.org/images/latest/checksums.txt
        factorcode_md5=`cat checksums.txt|grep $BOOT_IMAGE|cut -f2 -d' '`
        set_md5sum
        disk_md5=`$MD5SUM $BOOT_IMAGE|cut -f1 -d' '`
        $ECHO "Factorcode md5: $factorcode_md5";
        $ECHO "Disk md5: $disk_md5";
        if [[ "$factorcode_md5" == "$disk_md5" ]] ; then
            $ECHO "Your disk boot image matches the one on factorcode.org."
        else
            $DELETE $BOOT_IMAGE > /dev/null 2>&1
            get_boot_image;
        fi
    else
        get_boot_image
    fi
}

get_boot_image() {
    $ECHO "Downloading boot image $BOOT_IMAGE."
    get_url http://downloads.factorcode.org/images/latest/$BOOT_IMAGE
}

get_url() {
    if [[ -z $DOWNLOADER ]] ; then
        set_downloader;
    fi
    $ECHO $DOWNLOADER $1 ;
    $DOWNLOADER $1
    check_ret $DOWNLOADER
}

get_config_info() {
    find_build_info
    check_installed_programs
    check_libraries
}

copy_fresh_image() {
    $ECHO "Copying $FACTOR_IMAGE to $FACTOR_IMAGE_FRESH..."
    $COPY $FACTOR_IMAGE $FACTOR_IMAGE_FRESH
}

bootstrap() {
    ./$FACTOR_BINARY -i=$BOOT_IMAGE
    copy_fresh_image
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
    check_git_branch
    git_fetch_factorcode
    backup_factor
    make_clean_factor
}

download_and_bootstrap() {
    update_boot_images
    bootstrap
}

net_bootstrap_no_pull() {
    get_config_info
    make_clean_factor
    download_and_bootstrap
}

refresh_image() {
    ./$FACTOR_BINARY -script -e="USING: vocabs.loader vocabs.refresh system memory ; refresh-all save 0 exit"
    check_ret factor
}

make_boot_image() {
    ./$FACTOR_BINARY -script -e="\"$MAKE_IMAGE_TARGET\" USING: system bootstrap.image memory ; make-image save 0 exit"
    check_ret factor
}

install_deps_linux() {
    sudo apt-get --yes install libc6-dev libpango1.0-dev libx11-dev xorg-dev libgtk2.0-dev gtk2-engines-pixbuf libgtkglext1-dev wget git git-doc rlwrap gcc make
    check_ret sudo
}

install_deps_macosx() {
    test_program_installed git
    if [[ $? -ne 1 ]] ; then
        ensure_program_installed yes
        $ECHO "git not found."
        $ECHO "This script requires either git-core or port."
        $ECHO "If it fails, install git-core or port and try again."
        ensure_program_installed port
        $ECHO "Installing git-core with port...this will take awhile."
        yes | sudo port install git-core
    fi
}

usage() {
    $ECHO "usage: $0 command [optional-target]"
    $ECHO "  install - git clone, compile, bootstrap"
    $ECHO "  deps-linux - install required packages for Factor on Linux using apt-get"
    $ECHO "  deps-macosx - install git on MacOSX using port"
    $ECHO "  self-update - git pull, make local boot image, bootstrap"
    $ECHO "  quick-update - git pull, refresh-all, save"
    $ECHO "  update - git pull, download a boot image, recompile, bootstrap"
    $ECHO "  bootstrap - bootstrap with an existing boot image"
    $ECHO "  net-bootstrap - download a boot image, bootstrap"
    $ECHO "  make-target - find and print the os-arch-cpu string"
    $ECHO "  report - print the build variables"
    $ECHO ""
    $ECHO "If you are behind a firewall, invoke as:"
    $ECHO "env GIT_PROTOCOL=http $0 <command>"
    $ECHO ""
    $ECHO "Example for overriding the default target:"
    $ECHO "    $0 update macosx-x86-32"
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
    deps-linux) install_deps_linux ;;
    deps-macosx) install_deps_macosx ;;
    self-update) update; make_boot_image; bootstrap;;
    quick-update) update; refresh_image ;;
    update) update; download_and_bootstrap ;;
    bootstrap) get_config_info; bootstrap ;;
    net-bootstrap) net_bootstrap_no_pull ;;
    make-target) FIND_MAKE_TARGET=true; ECHO=false; find_build_info; exit_script ;;
    report) find_build_info ;;
    *) usage ;;
esac
