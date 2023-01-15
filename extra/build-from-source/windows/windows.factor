! Copyright (C) 2023 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors build-from-source html.parser
html.parser.analyzer http.client io.directories
io.encodings.utf8 io.files io.files.temp io.launcher
io.pathnames kernel multiline sequences windows.shell32 ;
IN: build-from-source.windows

! From `choco install -y nasm`
! Add nasm to path (windows+r sysdm.cpl -> Advanced tab -> Environment Variables -> New -> "c:\Program Files\NASM")
: check-nasm ( -- ) { "nasm.exe" "-h" } try-process ;

! From `choco install -y StrawberryPerl`
! make sure it is above the git /usr/bin/perl (if that is installed)
! TODO: https://stackoverflow.com/questions/5898131/set-a-persistent-environment-variable-from-cmd-exe
: check-perl ( -- ) { "perl" "-h" } try-process ;

! From vcvarsall.bat (x64 Native Tools Command Prompt runs this automatically)
: check-nmake ( -- ) { "nmake" "/?" } try-process ;
: check-cmake ( -- ) { "cmake" "-h" } try-process ;
: check-msbuild ( -- ) { "msbuild" "-h" } try-process ;

: build-openssl-64-dlls ( -- )
    "https://github.com/openssl/openssl.git" [
        check-perl
        program-files "NASM/nasm.exe" append-path "nasm.exe" prepend-current-path copy-file
        check-nasm
        check-nmake
        { "perl" "Configure" "VC-WIN64A" } try-process ! "VC-WIN32"
        { "nmake" } try-process
        { "openssl/apps/libssl-3-x64.dll" "openssl/apps/libcrypto-3-x64.dll" } copy-output-files
    ] with-updated-git-repo ;

: latest-pcre-tar-gz ( -- path )
    "https://ftp.exim.org/pub/pcre/" [
        http-get nip parse-html find-links concat
        [ name>> text = ] filter [ text>> ] map
        [ "pcre-" head? ] filter
        [ ".tar.gz" tail? ] filter last
    ] keep prepend ;

: build-pcre-dll ( -- )
    check-cmake
    check-msbuild
    latest-pcre-tar-gz [
        [
            { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" "-DPCRE_SUPPORT_UTF=ON" "-DPCRE_SUPPORT_UNICODE_PROPERTIES=ON" ".." } try-process
            { "msbuild" "PCRE.sln" "/m" } try-process
            "Debug/pcred.dll" copy-output-file
        ] with-build-directory
    ] with-tar-gz ;

: build-pcre2-dll ( -- )
    "https://github.com/PCRE2Project/pcre2.git" [
        [
            check-cmake
            check-msbuild
            { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" "-DPCRE_SUPPORT_UTF=ON" "-DPCRE_SUPPORT_UNICODE_PROPERTIES=ON" ".." } try-process
            { "msbuild" "PCRE2.sln" "/m" } try-process
            { "Debug/pcre2-8d.dll" "Debug/pcre2-posixd.dll" } copy-output-files
        ] with-build-directory
    ] with-updated-git-repo ;

! choco install -y winflexbison3
! win_flex.exe and win_bison.exe are copied in and renamed for postgres
: build-postgres-dll ( -- )
    "https://github.com/postgres/postgres" [
        "src/tools/msvc/clean.bat" prepend-current-path try-process
        [[ c:\ProgramData\chocolatey\bin\win_flex.exe]] "src/tools/msvc/flex.exe" prepend-current-path copy-file
        [[ c:\ProgramData\chocolatey\bin\win_bison.exe]] "src/tools/msvc/bison.exe" prepend-current-path copy-file
        [[ $ENV{MSBFLAGS}="/m";]] "src/tools/msvc/buildenv.bat" prepend-current-path utf8 set-file-contents
        "src/tools/msvc/build.bat" prepend-current-path try-process
        "Release/libpq/libpq.dll" copy-output-file
    ] with-updated-git-repo ;

! choco install -y glfw3
: build-raylib-dll ( -- )
    "https://github.com/raysan5/raylib.git" [
        [
            check-cmake
            check-msbuild
            { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" "-DBUILD_EXAMPLES=OFF" "-DUSE_EXTERNAL_GLFW=OFF" ".." } try-process
            { "msbuild" "raylib.sln" "/m" } try-process
            "raylib/Debug/raylib.dll" copy-output-file
        ] with-build-directory
    ] with-updated-git-repo ;

: build-snappy-dll ( -- )
    "https://github.com/google/snappy.git" [
        [
            { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" "-DSNAPPY_BUILD_TESTS=OFF" "-DSNAPPY_BUILD_BENCHMARKS=OFF" ".." } try-process
            { "msbuild" "Snappy.sln" "/m" } try-process
            "Debug/snappy.dll" copy-output-file
        ] with-build-directory
    ] with-updated-git-repo ;

: build-sqlite3-dll ( -- )
    "https://github.com/sqlite/sqlite.git" [
        check-nmake
        { "nmake" "/f" "Makefile.msc" "clean" } try-process
        { "nmake" "/f" "Makefile.msc" } try-process
        "sqlite3.dll" copy-output-file
    ] with-updated-git-repo ;

: build-yaml-dll ( -- )
    "https://github.com/yaml/libyaml.git" [
        [
            { "cmake" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
            { "msbuild" "yaml.sln" } try-process
            "Debug/yaml.dll" copy-output-file
        ] with-build-directory
    ] with-updated-git-repo ;

: build-zlib-dll ( -- )
    "https://github.com/madler/zlib" [
        check-nmake
        { "nmake" "/f" "win32/Makefile.msc" "clean" } try-process
        { "nmake" "/f" "win32/Makefile.msc" } try-process
        "zlib1.dll" copy-output-file
    ] with-updated-git-repo ;

! Probably not needed on Windows 10+
: install-windows-redistributable ( -- )
    [
        "https://aka.ms/vs/17/release/vc_redist.x64.exe" download
        { "vc_redist.x64.exe" "/install" "/passive" "/norestart" } try-process
    ] with-temp-directory ;

: build-windows-dlls ( -- )
    dll-out-directory remake-directory
    build-openssl-64-dlls
    build-postgres-dll
    build-raylib-dll
    build-snappy-dll
    build-sqlite3-dll
    build-yaml-dll
    build-zlib-dll ;
