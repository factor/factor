! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors build-from-source environment html.parser
html.parser.analyzer http.client io.backend io.directories
io.encodings.utf8 io.files io.files.temp io.launcher
io.pathnames kernel multiline qw sequences sorting.human
sorting.slots windows.shell32 ;
IN: build-from-source.windows

! choco install -y meson StrawberryPerl nasm winflexbison3 glfw3

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

: latest-fftw ( -- path )
    "https://ftp.fftw.org/pub/fftw/" [
        http-get nip
        parse-html find-links concat
        [ name>> text = ] filter
        [ text>> ] map
        [ "fftw-" head? ] filter
        [ ".tar.gz" tail? ] filter
        { human<=> } sort-by last
    ] keep prepend-path ;

: build-fftw-dll ( -- )
    latest-fftw [
        [
            { "cmake" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
            { "msbuild" "fftw.sln" "/m" "/property:Configuration=Release" } try-process
            "Release/fftw3.dll" copy-output-file
        ] with-build-directory
    ] with-tar-gz ;

: build-winflexbison ( -- )
    "https://github.com/lexxmark/winflexbison.git" [
        [
            { "cmake" ".." } try-process
            { "cmake" "--build" "." "--config" "Release" "--target" "package" } try-process
        ] with-build-directory
        "bin/Release/win_bison.exe" "bison.exe" copy-vm-file-as
        "bin/Release/win_flex.exe" "flex.exe" copy-vm-file-as
    ] with-updated-git-repo ;

: build-openssl-64-dlls ( -- )
    "https://github.com/openssl/openssl.git" [
        check-perl
        program-files "NASM/nasm.exe" append-path "nasm.exe" prepend-current-path copy-file
        check-nasm
        check-nmake
        { "perl" "Configure" "-DOPENSSL_PIC" "VC-WIN64A" } try-process ! "VC-WIN32"
        { "nmake" } try-process
        { "apps/libssl-3-x64.dll" "apps/libcrypto-3-x64.dll" } copy-output-files
    ] with-updated-git-repo ;

: latest-libressl ( -- path )
    "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/" [
        http-get nip parse-html find-links concat
        [ name>> text = ] filter
        [ text>> ] map
        [ "libressl-" head? ] filter
        [ ".tar.gz" tail? ] filter last
    ] keep prepend ;

: build-libressl-dlls ( -- )
    latest-libressl [
        [
            qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. } try-process
            qw{ msbuild LibreSSL.sln /m /property:Configuration=Release } try-process
            {
                "crypto/Release/crypto-50.dll"
                "ssl/Release/ssl-53.dll"
                "tls/Release/tls-26.dll"
            } copy-output-files
        ] with-build-directory
    ] with-tar-gz ;

: latest-pcre-tar-gz ( -- path )
    "https://ftp.exim.org/pub/pcre/" [
        http-get nip parse-html find-links concat
        [ name>> text = ] filter [ text>> ] map
        [ "pcre-" head? ] filter
        [ ".tar.gz" tail? ] filter last
    ] keep prepend ;

: build-pcre-dll ( -- )
    latest-pcre-tar-gz [
        [
            qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON .. } try-process
            qw{ msbuild PCRE.sln /m /property:Configuration=Release } try-process
            "Release/pcre.dll" copy-output-file
        ] with-build-directory
    ] with-tar-gz ;

: build-pcre2-dll ( -- )
    "https://github.com/PCRE2Project/pcre2.git" [
        [
            qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON .. } try-process
            qw{ msbuild PCRE2.sln /m /property:Configuration=Release } try-process
            { "Release/pcre2-8.dll" "Release/pcre2-posix.dll" } copy-output-files
        ] with-build-directory
    ] with-updated-git-repo ;

! choco install -y meson winflexbison3
: build-postgres-dll ( -- )
    "https://github.com/postgres/postgres" [
        "src/tools/msvc/clean.bat" prepend-current-path try-process
        qw{ meson setup build2 } try-process
        "build2" prepend-current-path
        [ { "ninja" } try-process ] with-directory
        "build2/src/interfaces/libpq/libpq.dll" copy-output-file
    ] with-updated-git-repo ;

! choco install -y glfw3
: build-raylib-dll ( -- )
    "https://github.com/raysan5/raylib.git" [
        [
            { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" "-DBUILD_EXAMPLES=OFF" "-DUSE_EXTERNAL_GLFW=OFF" ".." } try-process
            { "msbuild" "raylib.sln" "/m" "/property:Configuration=Release" } try-process
            "raylib/Release/raylib.dll" copy-output-file
        ] with-build-directory
    ] with-updated-git-repo ;

: build-snappy-dll ( -- )
    "https://github.com/google/snappy.git" [
        [
            { "cmake" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" "-DSNAPPY_BUILD_TESTS=OFF" "-DSNAPPY_BUILD_BENCHMARKS=OFF" ".." } try-process
            { "msbuild" "Snappy.sln" "/m" "/property:Configuration=Release" } try-process
            "Release/snappy.dll" copy-output-file
        ] with-build-directory
    ] with-updated-git-repo ;

: build-sqlite3-dll ( -- )
    "https://github.com/sqlite/sqlite.git" [
        { "nmake" "/f" "Makefile.msc" "clean" } try-process
        { "nmake" "/f" "Makefile.msc" } try-process
        "sqlite3.dll" copy-output-file
    ] with-updated-git-repo ;

: build-yaml-dll ( -- )
    "https://github.com/yaml/libyaml.git" [
        [
            qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
            qw{ msbuild yaml.sln /property:Configuration=Release } try-process

            "Release/yaml.dll" copy-output-file
        ] with-build-directory
    ] with-updated-git-repo ;

: build-zeromq-dll ( -- )
    "https://github.com/zeromq/libzmq.git" [
        [
            qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
            qw{ msbuild ZeroMQ.sln /property:Configuration=Release } try-process
            "bin/Release" find-dlls first "libzmq.dll" copy-output-file-as
        ] with-build-directory
    ] with-updated-git-repo ;

: build-zlib-dll ( -- )
    "https://github.com/madler/zlib" [
        { "nmake" "/f" "win32/Makefile.msc" "clean" } try-process
        { "nmake" "/f" "win32/Makefile.msc" } try-process
        "zlib1.dll" copy-output-file
    ] with-updated-git-repo ;

: build-lz4 ( -- )
    "https://github.com/lz4/lz4.git" [
        "build/cmake" [
            [
                qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
                qw{ msbuild LZ4.sln /property:Configuration=Release } try-process
                "Release/lz4.dll" copy-output-file
            ] with-build-directory
        ] with-directory
    ] with-updated-git-repo ;

: build-zstd-dll ( -- )
    "https://github.com/facebook/zstd.git" [
        qw{
            meson setup
            --buildtype=debugoptimized
            -Db_lundef=false
            -Dauto_features=enabled
            -Dbin_programs=true
            -Dbin_tests=true
            -Dbin_contrib=true
            -Ddefault_library=both
            -Dlz4=disabled
            build/meson builddir
        } try-process
        "builddir" prepend-current-path
        [
            { "ninja" } try-process
            "lib/zstd-1.dll" "libzstd.dll" copy-output-file-as
        ] with-directory
    ] with-updated-git-repo ;

! Probably not needed on Windows 10+
: install-windows-redistributable ( -- )
    [
        "https://aka.ms/vs/17/release/vc_redist.x64.exe" download
        qw{ vc_redist.x64.exe /install /passive /norestart } try-process
    ] with-temp-directory ;

: build-windows-dlls ( -- )
    dll-out-directory make-directories
    build-openssl-64-dlls
    build-libressl-dlls
    build-fftw-dll
    build-pcre-dll
    build-pcre2-dll
    build-postgres-dll
    build-raylib-dll
    build-snappy-dll
    build-sqlite3-dll
    build-yaml-dll
    build-zeromq-dll
    build-zlib-dll
    build-zstd-dll ;
