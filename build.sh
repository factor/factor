#!/usr/bin/env bash

# Programs returning != 0 will not cause script to exit
set +e

# Case insensitive string comparison
shopt -s nocaseglob
#shopt -s nocasematch

ECHO="echo"
OS=
ARCH=
WORD=
MUSL=${MUSL:=""}
GIT_PROTOCOL=${GIT_PROTOCOL:="https"}
GIT_URL=${GIT_URL:=$GIT_PROTOCOL"://github.com/factor/factor.git"}

test_program_installed() {
    command -v "$1" >/dev/null 2>&1
}

# return 1 on found
test_programs_installed() {
    local installed=0
    $ECHO -n "Checking for all($*)..."
    for cmd in "$@" ;
    do
        if test_program_installed "$cmd"; then
            ((installed++))
        fi
    done
    if [[ $installed -eq $# ]] ; then
        $ECHO "found!"
        return 0
    fi
    return 1
}

exit_script() {
    if [[ $FIND_MAKE_TARGET = true ]] ; then
        # not $ECHO here
        echo "$MAKE_TARGET"
    fi
    exit "$1"
}

ensure_program_installed() {
    local installed=0
    $ECHO -n "Checking for any($*)..."
    for cmd in "$@" ;
    do
        if test_program_installed "$cmd"; then
            $ECHO "found $cmd!"
            ((installed++))
            return
        fi
    done
    $ECHO "none found."
    $ECHO -n "Install "
    if [[ $# -eq 1 ]] ; then
        $ECHO -n "$1"
    else
        $ECHO -n "any of [ $* ]"
    fi
    $ECHO " and try again."
    if [[ $OS == macos ]] ; then
        $ECHO "If you have Xcode 4.3 or higher installed, you must install the"
        $ECHO "Command Line Tools from Xcode Preferences > Downloads in order"
        $ECHO "to build Factor."
    fi
    exit_script 1
}

check_ret() {
    # Can't execute any commands before saving $?
    # $1 is the name of the command we are checking
    RET=$?
    if [[ $RET -ne 0 ]] ; then
       $ECHO "$1" failed
       exit_script 2
    fi
}

download_with_wget() {
    local url="$1"
    local filename
    filename=$(basename "$url")
    $ECHO filename is "$filename"
    $ECHO wget -nd --prefer-family=IPv4 -O "$filename" "$url"
    wget -nd --prefer-family=IPv4 -O "$filename" "$url"
}

download_with_curl() {
    local url="$1"
    local filename
    filename=$(basename "$url")
    curl -L -f -o "$filename" "$url"
}

download_with_downloader() {
    local url="$1"
    if [[ -z $DOWNLOADER_NAME ]] ; then
        set_downloader
    fi
    if [[ $DOWNLOADER_NAME == 'wget' ]]; then
        download_with_wget "$url"
    elif [[ $DOWNLOADER_NAME == 'curl' ]]; then
        download_with_curl "$url"
    else
        $ECHO "error: wget or curl required in download_with_downloader"
        exit_script 12
    fi
}

set_downloader() {
    if test_program_installed wget; then
        DOWNLOADER_NAME=wget
        return
    fi
    if test_program_installed curl; then
        DOWNLOADER_NAME=curl
        return
    fi
    $ECHO "error: wget or curl required"
    exit_script 11
}

set_md5sum() {
    if test_program_installed md5sum; then
        MD5SUM=md5sum
    else
        MD5SUM="md5 -r"
    fi
}

set_cc() {
    # on Cygwin we MUST use the MinGW "cross-compilers", therefore check these first
    # furthermore, we prefer 64 bit over 32 bit versions if both are available

    # we need this condition so we don't find a mingw32 compiler on linux
    if [[ $OS == windows ]] ; then
        if test_programs_installed x86_64-w64-mingw32-gcc x86_64-w64-mingw32-g++; then
            [ -z "$CC" ] && CC=x86_64-w64-mingw32-gcc
            [ -z "$CXX" ] && CXX=x86_64-w64-mingw32-g++
            [ -z "$CC_OPT" ] && [ "$LTO" == "1" ] && CC_OPT="-flto=auto"
            [ -z "$CXX_OPT" ] && [ "$LTO" == "1" ] && CXX_OPT="-flto=auto"
            return
        fi

        if test_programs_installed i686-w64-mingw32-gcc i686-w64-mingw32-g++; then
            [ -z "$CC" ] && CC=i686-w64-mingw32-gcc
            [ -z "$CXX" ] && CXX=i686-w64-mingw32-g++
            [ -z "$CC_OPT" ] && [ "$LTO" == "1" ] && CC_OPT="-flto=auto"
            [ -z "$CXX_OPT" ] && [ "$LTO" == "1" ] && CXX_OPT="-flto=auto"
            return
        fi

        if test_programs_installed x86_64-w64-mingw32-clang x86_64-w64-mingw32-clang++; then
            [ -z "$CC" ] && CC=x86_64-w64-mingw32-clang
            [ -z "$CXX" ] && CXX=x86_64-w64-mingw32-clang++
            # [ -z "$CC_OPT" ] && [ "$LTO" == "1" ] && CC_OPT="-flto"
            # [ -z "$CXX_OPT" ] && [ "$LTO" == "1" ] && CXX_OPT="-flto"
            return
        fi

        if test_programs_installed i686-w64-mingw32-clang i686-w64-mingw32-clang++; then
            [ -z "$CC" ] && CC=i686-w64-mingw32-clang
            [ -z "$CXX" ] && CXX=i686-w64-mingw32-clang++
            # [ -z "$CC_OPT" ] && [ "$LTO" == "1" ] && CC_OPT="-flto"
            # [ -z "$CXX_OPT" ] && [ "$LTO" == "1" ] && CXX_OPT="-flto"
            return
        fi
    fi

    # Check for musl build - accept any non-empty value except explicit "0" or "false"
    if [[ -n "$MUSL" ]] && [[ "$MUSL" != "0" ]] && [[ "${MUSL,,}" != "false" ]]; then
        $ECHO "Building with static C/C++ runtime (musl-style)..."
        # For musl builds, statically link the C/C++ runtime but keep dlopen working
        # Full static linking breaks dlopen which Factor needs for FFI
        [ -z "$LDFLAGS" ] && LDFLAGS="-static-libgcc -static-libstdc++"
        # Don't override CFLAGS/CXXFLAGS, append to them
        SITE_CFLAGS="$SITE_CFLAGS -fno-stack-protector"
        SITE_CXXFLAGS="$SITE_CXXFLAGS -fno-stack-protector"
    fi

    # clang and clang++ commands will fail to correctly build Factor on Cygwin, need "cross compiler"
    if test_programs_installed clang clang++ ; then
        [ -z "$CC" ] && CC=clang
        [ -z "$CXX" ] && CXX=clang++
        [ -z "$CC_OPT" ] && [ "$LTO" == "1" ] && CC_OPT="-flto"
        [ -z "$CXX_OPT" ] && [ "$LTO" == "1" ] && CXX_OPT="-flto"
        return
    fi

    # gcc and g++ commands will fail to correctly build Factor on Cygwin, need "cross compiler"
    if test_programs_installed gcc g++ ; then
        [ -z "$CC" ] && CC=gcc
        [ -z "$CXX" ] && CXX=g++
        [ -z "$CC_OPT" ] && [ "$LTO" == "1" ] && CC_OPT="-flto=auto"
        [ -z "$CXX_OPT" ] && [ "$LTO" == "1" ] && CXX_OPT="-flto=auto"
        return
    fi

    $ECHO "error: high enough version of either (clang/clang++) or (gcc/g++) required!"
    exit_script 10
}

set_cc_versions() {
    CC_VERSION=$($CC --version | head -1)
    CXX_VERSION=$($CXX --version | head -1)
}

set_make() {
    case $OS in
        freebsd) MAKE="gmake" ;;
        *) MAKE="make" ;;
    esac
    if [[ $MAKE = "gmake" ]] ; then
        ensure_program_installed gmake
    fi
}

check_installed_programs() {
    ensure_program_installed chmod
    ensure_program_installed uname
    ensure_program_installed git
    ensure_program_installed wget curl
    ensure_program_installed clang x86_64-w64-mingw32-gcc i686-w64-mingw32-gcc gcc
    ensure_program_installed clang++ x86_64-w64-mingw32-g++ i686-w64-mingw32-g++ g++ cl
    ensure_program_installed make gmake
    ensure_program_installed md5sum md5
    ensure_program_installed cut
}

check_library_exists() {
    GCC_TEST=factor-library-test.c
    GCC_OUT=factor-library-test.out
    $ECHO -n "Checking for library $1..."
    $ECHO "int main(){return 0;}" > $GCC_TEST
    if $CC $GCC_TEST -o $GCC_OUT -l "$1" 2>&- ; then
        $ECHO "found."
    else
        $ECHO "not found."
    fi
    rm -f $GCC_TEST
    check_ret rm
    rm -f $GCC_OUT
    check_ret rm
}

check_X11_libraries() {
    check_library_exists GL
    check_library_exists X11
    check_library_exists pango-1.0
}

check_gtk_libraries() {
    check_library_exists gobject-2.0
    check_library_exists gtk-x11-2.0
    check_library_exists gdk-x11-2.0
    check_library_exists gdk_pixbuf-2.0
    check_library_exists gtkglext-x11-1.0
    check_library_exists atk-1.0
    check_library_exists gio-2.0
    check_library_exists gdkglext-x11-1.0
    check_library_exists pango-1.0
}


check_libraries() {
    case $OS in
        linux) check_X11_libraries
               check_gtk_libraries ;;
        unix) check_gtk_libraries ;;
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
    local uname_s
    uname_s=$(uname -s)
    check_ret uname
    case $uname_s in
        CYGWIN_NT-5.2-WOW64) OS=windows ;;
        *CYGWIN_NT*) OS=windows ;;
        *CYGWIN*) OS=windows ;;
        MINGW32*) OS=windows ;;
        MINGW64*) OS=windows ;;
        MSYS_NT*) OS=windows ;;
        *darwin*) OS=macos ;;
        *Darwin*) OS=macos ;;
        *linux*) OS=linux ;;
        *Linux*) OS=linux ;;
        FreeBSD) OS=freebsd ;;
        DragonFly) OS=freebsd ;;
        Haiku) OS=haiku ;;
    esac
}

find_architecture() {
    if [[ -n $ARCH ]] ; then return; fi
    $ECHO "Finding ARCH..."
    uname_m=$(uname -m)
    check_ret uname
    case $uname_m in
       i386) ARCH=x86 ;;
       i686) ARCH=x86 ;;
       i86pc) ARCH=x86 ;;
       amd64) ARCH=x86 ;;
       ppc64) ARCH=ppc ;;
       *86) ARCH=x86 ;;
       *86_64) ARCH=x86 ;;
       aarch64) ARCH=arm ;;
       arm64) ARCH=arm ;;
       iPhone5*[3-9]) ARCH=arm ;;
       iPhone[6-9]*) ARCH=arm ;;
       iPhone[1-9][0-9]*) ARCH=arm ;;
       iPad[4-9]*) ARCH=arm ;;
       iPad[1-9][0-9]*) ARCH=arm ;;
       AppleTV[5-9]*) ARCH=arm ;;
       AppleTV[1-9][0-9]*) ARCH=arm ;;
       "Power Macintosh") ARCH=ppc ;;
    esac
}

find_num_cores() {
    $ECHO "Finding NUM_CORES..."
    NUM_CORES=1
    uname_s=$(uname -s)
    check_ret uname
    case $uname_s in
        CYGWIN_NT-5.2-WOW64 | *CYGWIN_NT* | *CYGWIN* | MINGW32*) NUM_CORES=$NUMBER_OF_PROCESSORS ;;
        *linux* | *Linux*) NUM_CORES=$(getconf _NPROCESSORS_ONLN || nproc) ;;
        *darwin* | *Darwin* | freebsd) NUM_CORES=$(sysctl -n hw.ncpu) ;;
    esac
}

find_word_size() {
    if [[ -n $WORD ]] ; then return; fi
    $ECHO "Finding WORD..."
    WORD=$(getconf LONG_BIT || find_word_size_cpp || find_word_size_c)
}

find_word_size_cpp() {
    SIXTY_FOUR='defined(__aarch64__) || defined(__x86_64__) || defined(_M_AMD64) || defined(__PPC64__) || defined(__64BIT__)'
    THIRTY_TWO='defined(i386) || defined(__i386) || defined(__i386__) || defined(_MIX86)'
    $CC -E -xc <(echo -e "#if ${SIXTY_FOUR}\n64\n#elif ${THIRTY_TWO}\n32\n#endif") | tail -1
}

find_word_size_c() {
    C_WORD="factor-word-size"
    TEST_PROGRAM="int main(){ return (long)(8*sizeof(void*)); }"
    echo "$TEST_PROGRAM" | $CC -o $C_WORD -xc -
    check_ret "$CC"
    ./$C_WORD
    WORD_OUT=$?
    case $WORD_OUT in
        32) ;;
        64) ;;
        *)
            echo "Word size should be 32/64, got '$WORD_OUT'"
            exit_script 15 ;;
    esac
    rm -f $C_WORD
    echo "$WORD_OUT"
}

set_factor_binary() {
    case $OS in
        windows) FACTOR_BINARY=factor.com ;;
        *) FACTOR_BINARY=factor ;;
    esac
}

set_factor_library() {
    case $OS in
        windows) FACTOR_LIBRARY=factor.dll ;;
        macos) FACTOR_LIBRARY=libfactor.dylib ;;
        *) FACTOR_LIBRARY=libfactor.a ;;
    esac
}

set_factor_image() {
    FACTOR_IMAGE=factor.image
    FACTOR_IMAGE_FRESH=factor.image.fresh
}

echo_build_info() {
    $ECHO "OS=$OS"
    $ECHO "ARCH=$ARCH"
    $ECHO "NUM_CORES=$NUM_CORES"
    $ECHO "WORD=$WORD"
    $ECHO "DEBUG=$DEBUG"
    $ECHO "REPRODUCIBLE=$REPRODUCIBLE"
    $ECHO "CURRENT_BRANCH=$CURRENT_BRANCH"
    $ECHO "CURRENT_BRANCH_FULL=$CURRENT_BRANCH_FULL"
    $ECHO "FACTOR_BINARY=$FACTOR_BINARY"
    $ECHO "FACTOR_LIBRARY=$FACTOR_LIBRARY"
    $ECHO "FACTOR_IMAGE=$FACTOR_IMAGE"
    $ECHO "MAKE_TARGET=$MAKE_TARGET"
    $ECHO "BOOT_IMAGE=$BOOT_IMAGE"
    $ECHO "MAKE_IMAGE_TARGET=$MAKE_IMAGE_TARGET"
    $ECHO "GIT_PROTOCOL=$GIT_PROTOCOL"
    $ECHO "GIT_URL=$GIT_URL"
    $ECHO "CHECKSUM_URL=$CHECKSUM_URL"
    $ECHO "BOOT_IMAGE_URL=$BOOT_IMAGE_URL"
    $ECHO "DOWNLOADER_NAME=$DOWNLOADER_NAME"
    $ECHO "CC=$CC"
    $ECHO "CXX=$CXX"
    $ECHO "CC_VERSION=$CC_VERSION"
    $ECHO "CXX_VERSION=$CXX_VERSION"
    $ECHO "LTO=$LTO"
    $ECHO "MUSL=$MUSL"
    $ECHO "CC_OPT=$CC_OPT"
    $ECHO "CXX_OPT=$CXX_OPT"
    $ECHO "MAKE=$MAKE"
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
    if [[ $OS == "windows" ]] ; then
        MAKE_IMAGE_TARGET=windows-$ARCH.$WORD
        MAKE_TARGET=$OS-$ARCH-$WORD
    else
        MAKE_IMAGE_TARGET=unix-$ARCH.$WORD
        MAKE_TARGET=$OS-$ARCH-$WORD
    fi
    BOOT_IMAGE=boot.$MAKE_IMAGE_TARGET.image
}

parse_build_info() {
    ensure_program_installed cut
    $ECHO "Parsing make target from command line: $1"
    OS=$(echo "$1" | cut -d '-' -f 1)
    ARCH=$(echo "$1" | cut -d '-' -f 2)
    WORD=$(echo "$1" | cut -d '-' -f 3)

    if [[ $OS == linux && $ARCH == ppc ]] ; then WORD=32; fi
    if [[ $OS == linux && $ARCH == arm ]] ; then WORD=32; fi
    if [[ $OS == macos && $ARCH == ppc ]] ; then WORD=32; fi

    $ECHO "OS=$OS"
    $ECHO "ARCH=$ARCH"
    $ECHO "WORD=$WORD"
}

prepare_build_info() {
    find_os
    find_architecture
    find_num_cores
    set_cc
    set_cc_versions
    find_word_size
    set_current_branch
    set_factor_binary
    set_factor_library
    set_factor_image
    set_build_info
    set_downloader
    set_boot_image_vars
    set_make
}

find_build_info() {
    prepare_build_info
    echo_build_info
}

invoke_git() {
    git "$@"
    check_ret git
}

git_clone() {
    $ECHO "Downloading the git repository from github.com..."
    invoke_git clone "$GIT_URL"
}

update_script_name() {
    $ECHO "$(dirname "$0")/_update.sh"
}

update_script() {
  set_current_branch
  local -r update_script=$(update_script_name)
  local -r shell_path="$SHELL"
  {
    echo "#!$shell_path"
    echo "set -ex"
    echo "git pull ${GIT_URL} ${CURRENT_BRANCH}"
    echo "exit 0"
  } > "$update_script"
  chmod 755 "$update_script"
  $ECHO "Running the build.sh updater script: $update_script"
  exec "$update_script"
}

update_script_changed() {
    invoke_git diff --stat "$(invoke_git merge-base HEAD FETCH_HEAD)" FETCH_HEAD | grep "build.sh" >/dev/null
}

git_fetch() {
    $ECHO "Fetching the git repository from github.com..."
    set_current_branch

    rm -f "$(update_script_name)"
    $ECHO git fetch "$GIT_URL" "${CURRENT_BRANCH}"
    invoke_git fetch "$GIT_URL" "${CURRENT_BRANCH}"

    if update_script_changed; then
        $ECHO "Updating and restarting the build.sh script..."
        update_script
    else
        $ECHO "Updating the working tree..."
        invoke_git pull "$GIT_URL" "${CURRENT_BRANCH}"
    fi
}

cd_factor() {
    cd "factor" || exit 12
    check_ret cd
}

backup_factor() {
    $ECHO "Backing up factor..."
    cp "$FACTOR_BINARY" "$FACTOR_BINARY.bak"
    cp "$FACTOR_LIBRARY" "$FACTOR_LIBRARY.bak"
    cp "$BOOT_IMAGE" "$BOOT_IMAGE.bak"
    cp "$FACTOR_IMAGE" "$FACTOR_IMAGE.bak"
    $ECHO "Done with backup."
}

check_makefile_exists() {
    if [[ ! -e "GNUmakefile" ]] ; then
        $ECHO ""
        $ECHO "***GNUmakefile not found***"
        $ECHO "You are likely in the wrong directory."
        $ECHO "Run this script from your factor directory:"
        $ECHO "     ./build.sh"
        exit_script 6
    fi
}

invoke_make() {
    check_makefile_exists
    if [ -n "$MAKE_OPTS" ]; then
        "$MAKE" "$MAKE_OPTS" "$@"
    else
        "$MAKE" "$@"
    fi
    check_ret $MAKE
}

make_clean() {
    invoke_make clean
}

make_factor() {
    $ECHO "Building factor with $NUM_CORES cores"
    $ECHO invoke_make "CC=$CC" "CXX=$CXX" "CC_OPT=$CC_OPT" "CXX_OPT=$CXX_OPT" "SITE_CFLAGS=$SITE_CFLAGS" "SITE_CXXFLAGS=$SITE_CXXFLAGS" "LDFLAGS=$LDFLAGS" "$MAKE_TARGET" "-j$NUM_CORES"
    invoke_make "CC=$CC" "CXX=$CXX" "CC_OPT=$CC_OPT" "CXX_OPT=$CXX_OPT" "SITE_CFLAGS=$SITE_CFLAGS" "SITE_CXXFLAGS=$SITE_CXXFLAGS" "LDFLAGS=$LDFLAGS" "$MAKE_TARGET" "-j$NUM_CORES"
}

make_clean_factor() {
    make_clean
    make_factor
}

current_git_branch() {
    # git rev-parse --abbrev-ref HEAD # outputs HEAD for detached head
    # outputs nothing for detached HEAD, which is fine for ``git fetch``
    git describe --all --exact-match 2>/dev/null
}


check_url() {
    if [[ $DOWNLOADER_NAME == 'wget' ]]; then
        wget -S --spider --prefer-family=IPv4 "$1" 2>&1 | grep -q 'HTTP/[12].[01] [23]..' && return 0 || return 1
    elif [[ $DOWNLOADER_NAME == 'curl' ]]; then
        curl -4 -sL -w "%{http_code}\\n" "$1" -o /dev/null | grep -qE '^(2[0-9]{2})$' && return 0 || return 1
    else
        echo "error: wget or curl required to check URL"
        exit 12
    fi
}

# If we are on a branch, first try to get a boot image for that branch.
# Otherwise, just use `master`
set_boot_image_vars() {
    set_current_branch
    local url="https://downloads.factorcode.org/images/${CURRENT_BRANCH}/checksums.txt"
    $ECHO "Getting checksum from ${url}"

    if check_url "$url"; then
        $ECHO "got checksum!"
        CHECKSUM_URL="$url"
        BOOT_IMAGE_URL="https://downloads.factorcode.org/images/${CURRENT_BRANCH}/${BOOT_IMAGE}"
    else
        $ECHO "boot image for branch \`${CURRENT_BRANCH}\` is not on server, trying master instead"
        $ECHO "  tried nonexistent url: ${url}"
        CHECKSUM_URL="https://downloads.factorcode.org/images/master/checksums.txt"
        BOOT_IMAGE_URL="https://downloads.factorcode.org/images/master/${BOOT_IMAGE}"
    fi
}

set_current_branch() {
    if [ -n "${CI_BRANCH}" ]; then
        CURRENT_BRANCH="${CI_BRANCH}"
    else
        CURRENT_BRANCH_FULL=$(current_git_branch)
        CURRENT_BRANCH=$($ECHO "$CURRENT_BRANCH_FULL" | sed 's=heads/==;s=remotes/==')
    fi
}

update_boot_image() {
    set_boot_image_vars
    $ECHO "Deleting old images..."
    rm -f checksums.txt* > /dev/null 2>&1
    rm -f "$BOOT_IMAGE".{?,??} > /dev/null 2>&1
    rm -f temp/staging.*.image > /dev/null 2>&1
    if [[ -f $BOOT_IMAGE ]] ; then
        get_url "$CHECKSUM_URL"
        local factorcode_md5
        factorcode_md5=$(grep "$BOOT_IMAGE" checksums.txt | cut -f2 -d' ')
        set_md5sum
        local disk_md5
        disk_md5=$($MD5SUM "$BOOT_IMAGE" | cut -f1 -d' ')
        $ECHO "Factorcode md5: $factorcode_md5"
        $ECHO "Disk md5: $disk_md5"
        if [[ "$factorcode_md5" == "$disk_md5" ]] ; then
            $ECHO "Your disk boot image matches the one on downloads.factorcode.org."
        else
            rm -f "$BOOT_IMAGE" > /dev/null 2>&1
            get_boot_image
        fi
    else
        get_boot_image
    fi
}

get_boot_image() {
    $ECHO "Downloading boot image $BOOT_IMAGE."
    get_url "${BOOT_IMAGE_URL}"
}

get_url() {
    if [[ -z $DOWNLOADER_NAME ]] ; then
        set_downloader_name
    fi
    download_with_downloader "$1"
}

get_config_info() {
    find_build_info
    check_installed_programs
    check_libraries
}

copy_fresh_image() {
    $ECHO "Copying $FACTOR_IMAGE to $FACTOR_IMAGE_FRESH..."
    cp "$FACTOR_IMAGE" "$FACTOR_IMAGE_FRESH"
}

check_launch_factor() {
    "./$FACTOR_BINARY" -e=
    check_ret "Could not launch ./$FACTOR_BINARY"
}

is_boot_image_outdated() {
    "./$FACTOR_BINARY" "-e=USE: system \"\" to-refresh 2drop length 0 > 1 0 ? exit"
    return $?
}

info_boot_image() {
    prepare_build_info
    if [[ -f $BOOT_IMAGE ]] ; then
        get_url "$CHECKSUM_URL"
        local factorcode_md5
        factorcode_md5=$(grep "$BOOT_IMAGE" checksums.txt | cut -f2 -d' ')
        set_md5sum
        local disk_md5
        disk_md5=$($MD5SUM "$BOOT_IMAGE" | cut -f1 -d' ')
        $ECHO "Boot image @factorcode.org md5: $factorcode_md5"
        $ECHO "Boot image @local disk     md5: $disk_md5"
        if [[ "$factorcode_md5" == "$disk_md5" ]] ; then
            $ECHO "Your disk boot image matches the one on downloads.factorcode.org."
        else
            $ECHO "Your disk boot image and the one on downloads.factorcode.org mismatch"
        fi
    fi
}

info_check_factor_refresh_all_locally() {
    prepare_build_info
    check_launch_factor

    if is_boot_image_outdated; then
        $ECHO "Your Factor image is consistent with the local source code."
    else
        $ECHO "Your Factor image is not consistent with the local source code."
    fi
}

bootstrap() {
    ./$FACTOR_BINARY -i="$BOOT_IMAGE"
    check_ret "./$FACTOR_BINARY bootstrap failed"
    copy_fresh_image
}

install() {
    check_factor_exists
    get_config_info
    git_clone
    cd_factor
    make_factor
    set_boot_image_vars
    get_boot_image
    bootstrap
}

update() {
    get_config_info
    git_fetch
    backup_factor
    make_clean_factor
}

download_and_bootstrap() {
    update_boot_image
    bootstrap
}

net_bootstrap_no_pull() {
    get_config_info
    make_clean_factor
    download_and_bootstrap
}

refresh_image() {
    ./$FACTOR_BINARY -e="USING: vocabs.loader vocabs.refresh system memory ; refresh-all save quit"
    check_ret factor
}

make_boot_image() {
    ./$FACTOR_BINARY -run="bootstrap.image" "$MAKE_IMAGE_TARGET"
    check_ret factor
}

install_deps_apt() {
    sudo apt install --yes libc6-dev libpango1.0-dev libx11-dev xorg-dev libgtk2.0-dev gtk2-engines-pixbuf libgtkglext1-dev wget git git-doc rlwrap clang make screen tmux libssl-dev
    check_ret sudo
}

install_deps_pacman() {
    sudo pacman --noconfirm -Syu gcc clang make rlwrap git wget pango glibc gtk2 gtk3 gtkglext gtk-engines gdk-pixbuf2 libx11 screen tmux
    check_ret sudo
}

install_deps_dnf() {
    sudo dnf --assumeyes install gcc gcc-c++ glibc-devel binutils libX11-devel pango-devel gtk3-devel gdk-pixbuf2-devel gtkglext-devel tmux rlwrap wget
    check_ret sudo
}

install_deps_pkg() {
    sudo pkg install --yes bash git gmake gcc rlwrap ripgrep curl gmake x11-toolkits/gtk30 x11-toolkits/gtkglext pango cairo vim
}

install_deps_apk() {
    sudo apk add --no-cache bash git make gcc g++ libc-dev musl-dev pango-dev libx11-dev gtk+2.0-dev wget rlwrap clang tmux screen openssl-dev glu-dev mesa-dev
    check_ret sudo
}


install_deps_macos() {
    if test_program_installed git; then
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
    $ECHO "  deps-apt - install required packages for Factor on Linux using apt"
    $ECHO "  deps-pacman - install required packages for Factor on Linux using pacman"
    $ECHO "  deps-dnf - install required packages for Factor on Linux using dnf"
    $ECHO "  deps-pkg - install required packages for Factor on FreeBSD using pkg"
    $ECHO "  deps-apk - install required packages for Factor on Alpine Linux using apk"
    $ECHO "  deps-macos - install git on macOS using port"
    $ECHO "  info-boot-image - print remote and disk boot image MD5"
    $ECHO "  info-check-factor-refresh-all-locally - check if local sources would cause refresh-all to change the image"
    $ECHO "  self-bootstrap - make local boot image, bootstrap"
    $ECHO "  self-update - git pull, recompile, make local boot image, bootstrap"
    $ECHO "  quick-update - git pull, refresh-all, save"
    $ECHO "  update|latest - git pull, recompile, download a boot image, bootstrap"
    $ECHO "  clean - run make clean"
    $ECHO "  compile - compile the binary"
    $ECHO "  recompile - recompile the binary"
    $ECHO "  bootstrap - bootstrap with existing boot image"
    $ECHO "  net-bootstrap - recompile, download a boot image, bootstrap"
    $ECHO "  make-target - find and print the os-arch-cpu string"
    $ECHO "  report|info - print the build variables"
    $ECHO "  full-report - print the build variables, check programs and libraries"
    $ECHO "  update-boot-image - get the boot image for the current branch"
    $ECHO ""
    $ECHO "If you are behind a firewall, invoke as:"
    $ECHO "env GIT_PROTOCOL=http $0 <command>"
    $ECHO ""
    $ECHO "To build with musl libc (static linking), invoke as:"
    $ECHO "env MUSL=1 $0 <command>"
    $ECHO ""
    $ECHO "Example for overriding the default target:"
    $ECHO "    $0 update macos-x86-32"
}

MAKE_TARGET=unknown

# -n is nonzero length, -z is zero length
if [[ -n "$2" ]] ; then
    parse_build_info "$2"
fi

if [ "$#" -gt 3 ]; then
    usage
    $ECHO "error: too many arguments"
    exit 1
fi

case "$1" in
    install) install ;;
    deps-apt) install_deps_apt ;;
    deps-pacman) install_deps_pacman ;;
    deps-macos) install_deps_macos ;;
    deps-dnf) install_deps_dnf ;;
    deps-pkg) install_deps_pkg ;;
    deps-apk) install_deps_apk ;;
    info-boot-image) info_boot_image ;;
    info-check-factor-refresh-all-locally) info_check_factor_refresh_all_locally ;;
    update-boot-image) find_build_info; check_installed_programs; update_boot_image ;;
    self-bootstrap) get_config_info; make_boot_image; bootstrap  ;;
    self-update) update; make_boot_image; bootstrap  ;;
    quick-update) update; refresh_image ;;
    update|latest) update; download_and_bootstrap ;;
    clean) find_build_info; make_clean ;;
    compile) find_build_info; make_factor ;;
    recompile) find_build_info; make_clean; make_factor ;;
    bootstrap) get_config_info; bootstrap ;;
    net-bootstrap) net_bootstrap_no_pull ;;
    make-target) FIND_MAKE_TARGET=true; ECHO=false; find_build_info; exit_script 0;;
    report|info) find_build_info ;;
    full-report) find_build_info; check_installed_programs; check_libraries ;;
    update-script) update_script ;;
    *) usage ;;
esac
