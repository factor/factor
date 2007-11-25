#!/bin/bash -e

# Programs returning != 0 will not cause script to exit
set +e

# Case insensitive string comparison
shopt -s nocaseglob
#shopt -s nocasematch

OS=
ARCH=
WORD=
NO_UI=

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
	   exit 2
	fi
}

check_gcc_version() {
	GCC_VERSION=`gcc --version`
	if [[ $GCC_VERSION == *3.3.* ]] ; then
		echo "You have a known buggy version of gcc (3.3)"
		echo "Install gcc 3.4 or higher and try again."
		exit 3
	fi
}

check_installed_programs() {
	ensure_program_installed chmod
	ensure_program_installed uname
	ensure_program_installed git
	ensure_program_installed wget
	ensure_program_installed gcc
	ensure_program_installed make
	check_gcc_version
}

check_library_exists() {
	GCC_TEST=factor-library-test.c
	GCC_OUT=factor-library-test.out
	echo "Checking for library $1"
	echo "int main(){return 0;}" > $GCC_TEST
	gcc $GCC_TEST -o $GCC_OUT -l $1
	if [[ $? -ne 0 ]] ; then
		echo "Warning: library $1 not found."
		echo "***Factor will compile NO_UI=1"
		NO_UI=1
	fi
	rm -f GCC_TEST
	rm -f GCC_OUT
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
	uname_s=`uname -s`
	case $uname_s in
		CYGWIN_NT-5.2-WOW64) OS=windows-nt;;
		*CYGWIN_NT*) OS=windows-nt;;
		*CYGWIN*) OS=windows-nt;;
		*darwin*) OS=macosx;;
		*Darwin*) OS=macosx;;
		*linux*) OS=linux;;
		*Linux*) OS=linux;;
	esac
}

find_architecture() {
	uname_m=`uname -m`
	case $uname_m in
	   i386) ARCH=x86;;
	   i686) ARCH=x86;;
	   *86) ARCH=x86;;
	   "Power Macintosh") ARCH=ppc;;
	esac
}

write_test_program() {
	echo "#include <stdio.h>" > $C_WORD.c
	echo "int main(){printf(\"%d\", 8*sizeof(void*)); return 0; }" >> $C_WORD.c
}

find_word_size() {
	C_WORD=factor-word-size
	write_test_program
	gcc -o $C_WORD $C_WORD.c
	WORD=$(./$C_WORD)
	check_ret $C_WORD
	rm -f $C_WORD*
}

set_factor_binary() {
	case $OS in
		windows-nt) FACTOR_BINARY=factor-nt;;
		macosx) FACTOR_BINARY=./Factor.app/Contents/MacOS/factor;;
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
}

set_build_info() {
	if ! [[ -n $OS && -n $ARCH && -n $WORD ]] ; then
		echo "OS, ARCH, or WORD is empty.  Please report this"
		exit 5
	fi
	
	MAKE_TARGET=$OS-$ARCH-$WORD
	BOOT_IMAGE=boot.$ARCH.$WORD.image
	if [[ $OS == macosx && $ARCH=ppc ]] ; then
		MAKE_TARGET=$OS-$ARCH
		BOOT_IMAGE=boot.macosx-ppc.image
	fi
}

find_build_info() {
	find_os
	find_architecture
	find_word_size
	set_factor_binary
	set_build_info
	echo_build_info
}

git_clone() {
	echo "Downloading the git repository from factorcode.org..."
	git clone git://factorcode.org/git/factor.git
	check_ret git
}

git_pull_factorcode() {
	git pull git://factorcode.org/git/factor.git
	check_ret git
}

cd_factor() {
	cd factor
	check_ret cd
}

make_clean() {
	make clean
	check_ret make
}

make_factor() {
	make NO_UI=$NO_UI $MAKE_TARGET -j5
	check_ret make
}

delete_boot_images() {
	echo "Deleting old images..."
	rm $BOOT_IMAGE > /dev/null 2>&1
	rm $BOOT_IMAGE.* > /dev/null 2>&1
}

get_boot_image() {
	wget http://factorcode.org/images/latest/$BOOT_IMAGE
	check_ret wget
}

maybe_download_dlls() {
	if [[ $OS == windows-nt ]] ; then
		wget http://factorcode.org/dlls/freetype6.dll
		check_ret
		wget http://factorcode.org/dlls/zlib1.dll
		check_ret
		chmod 777 *.dll
		check_ret
	fi
}

bootstrap() {
	./$FACTOR_BINARY -i=$BOOT_IMAGE
}

usage() {
	echo "usage: $0 install|update"
}

install() {
	check_factor_exists
	check_installed_programs
	find_build_info
	check_libraries
	git_clone
	cd_factor
	make_factor
	get_boot_image
	maybe_download_dlls
	bootstrap
}

update() {
	check_installed_programs
	find_build_info
	check_libraries
	git_pull_factorcode
	make_clean
	make_factor
	delete_boot_images
	get_boot_image
	bootstrap
}

case "$1" in
	install) install ;;
	update) update ;;
	*) usage ;;
esac
