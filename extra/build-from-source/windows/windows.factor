! Copyright (C) 2023 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cli.git formatting io.directories io.files.temp
io.launcher io.pathnames kernel layouts multiline namespaces
system ;
IN: build-from-source.windows

! choco install -y StrawberryPerl nasm 
! Add nasm to path (windows+r sysdm.cpl -> Advanced tab -> Environment Variables -> New -> "c:\Program Files\NASM")
! make sure it is above the git /usr/bin (if that is installed)
! strawberryperl nasm
! https://stackoverflow.com/questions/5898131/set-a-persistent-environment-variable-from-cmd-exe

: dll-out-directory ( -- path )
    vm-path parent-directory cell-bits "dlls%s-out" sprintf append-path
    dup make-directories ;

: append-current-path ( path -- path' )
    [ current-directory get ] dip append-path ;

: with-updated-git-repo-as ( git-uri path quot -- )
    '[
        _ _ [
            sync-repository wait-for-success
        ] keep
        append-current-path _ with-directory
    ] with-temp-directory ; inline

: with-updated-git-repo ( git-uri quot -- )
    [ dup git-directory-name ] dip with-updated-git-repo-as ; inline

: build-sqlite3-dll ( -- )
    "https://github.com/sqlite/sqlite.git"
    [
        ! "sqlite" repo-directory current-directory set
        { "nmake" "/f" "Makefile.msc" "clean" } try-process
        { "nmake" "/f" "Makefile.msc" } try-process
        "sqlite3.dll" append-current-path
        dll-out-directory copy-file-into
    ] with-updated-git-repo ;

: build-openssl-64-dlls ( -- )
    [
        "https://github.com/openssl/openssl.git" sync-repository wait-for-success
        "openssl" repo-directory current-directory set
        { "perl" "Configure" "VC-WIN64A" } try-process  ! VC-WIN32
        { "nmake" } try-process

        "openssl/apps/libssl-3-x64.dll" repo-directory
        dll-out-directory copy-file-into

        "openssl/apps/libcrypto-3-x64.dll" repo-directory
        dll-out-directory copy-file-into

        ! "openssl/apps/libssl-3-x64.dll" repo-directory
        ! dll-out-directory "libssl-38.dll" append-path copy-file

        ! "openssl/apps/libcrypto-3-x64.dll" repo-directory
        ! dll-out-directory "libcrypto-38.dll" append-path copy-file
    ] with-temp-directory ;

: build-libressl-dlls ( -- )
    [
        "https://github.com/libressl/portable.git" sync-repository wait-for-success
        "portable" repo-directory current-directory set

        "portable" repo-directory current-directory set
        "portable/build" repo-directory ?delete-tree
        "portable/build" repo-directory make-directories
        "portable/build" repo-directory current-directory set
        { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
        { "msbuild" "portable.sln" } try-process
        ! { "nmake" "test" } try-process

        ! "openssl/apps/libssl-3-x64.dll" repo-directory
        ! dll-out-directory copy-file-into

        ! "openssl/apps/libcrypto-3-x64.dll" repo-directory
        ! dll-out-directory copy-file-into

        "openssl/apps/libssl-3-x64.dll" repo-directory
        dll-out-directory "libssl-38.dll" append-path copy-file

        "openssl/apps/libcrypto-3-x64.dll" repo-directory
        dll-out-directory "libcrypto-38.dll" append-path copy-file
    ] with-temp-directory ;
: build-pcre2-dll ( -- )
    [
        "https://github.com/PCRE2Project/pcre2.git" sync-repository wait-for-success
        "pcre2" repo-directory current-directory set
        "pcre2/build" repo-directory ?delete-tree
        "pcre2/build" repo-directory make-directories
        "pcre2/build" repo-directory current-directory set
        { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
        { "msbuild" "PCRE2.sln" } try-process

        "pcre2/build/Debug/pcre2-8d.dll" repo-directory
        dll-out-directory copy-file-into

        "pcre2/build/Debug/pcre2-posixd.dll" repo-directory
        dll-out-directory copy-file-into
    ] with-temp-directory ;

: build-sqlite3-dll2 ( -- )
    [
        "https://github.com/sqlite/sqlite.git" sync-repository wait-for-success
        "sqlite" repo-directory current-directory set
        { "nmake" "/f" "Makefile.msc" "clean" } try-process
        { "nmake" "/f" "Makefile.msc" } try-process      
        "sqlite/sqlite3.dll" repo-directory
        dll-out-directory copy-file-into
    ] with-temp-directory ;

: build-zlib-dll ( -- )
    [
        "https://github.com/madler/zlib" sync-repository wait-for-success
        current-temp-directory get "zlib" append-path current-directory set
        { "nmake" "/f" "win32/Makefile.msc" "clean" } try-process
        { "nmake" "/f" "win32/Makefile.msc" } try-process      
        current-temp-directory get "zlib/zlib1.dll" append-path
        dll-out-directory copy-file-into
    ] with-temp-directory ;

: check-nasm ( -- ) { [[ C:\Program Files\NASM\nasm.exe]] } try-process ;
: check-nmake ( -- ) { "nmake" "/?" } try-process ;

: build-windows-dlls ( -- )
    check-nmake
    dll-out-directory ?delete-tree
    build-sqlite3-dll
    build-zlib-dll ;
