! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors build-from-source continuations environment
html.parser html.parser.analyzer http.client io.directories
io.files.temp io.launcher io.pathnames kernel layouts qw
sequences sorting.human windows.shell32 ;
IN: build-from-source.windows

! choco install -y meson StrawberryPerl nasm winflexbison3 glfw3 jom
! jom is for building openssl in parallel

! From `choco install -y nasm`
! Add nasm to path (windows+r sysdm.cpl -> Advanced tab -> Environment Variables -> New -> "c:\Program Files\NASM")
: check-nasm ( -- ) { "nasm.exe" "-h" } try-process ;
: have-jom? ( -- ? ) [ { "jom" } try-process t ] [ drop f ] recover ;

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
        human-sort last
    ] keep prepend-path ;

: build-fftw-dll ( -- )
    latest-fftw [
        [
            32-bit? [
                { "cmake" "-G" "Visual Studio 17 2022" "-A" "Win32" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
                qw{ msbuild fftw.sln /m /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
                qw{ msbuild fftw.sln /m /property:Configuration=Release } try-process
            ] if
            "Release/fftw3.dll" copy-output-file
        ] with-build-directory
    ] with-tar-gz ;

: build-winflexbison ( -- )
    "lexxmark" "winflexbison" [
        [
            qw{ cmake .. } try-process
            qw{ cmake --build . --config Release --target package } try-process
        ] with-build-directory
        "bin/Release/win_bison.exe" "bison.exe" copy-vm-file-as
        "bin/Release/win_flex.exe" "flex.exe" copy-vm-file-as
    ] with-updated-github-repo ;

: build-blas ( -- )
    "xianyi" "OpenBLAS" [
        [
            32-bit? [
                { "cmake" "-G" "Visual Studio 17 2022" "-A" "Win32" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
                qw{ msbuild OpenBLAS.sln /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                { "cmake" "-G" "Visual Studio 17 2022" "-DCMAKE_BUILD_TYPE=Release" "-DBUILD_SHARED_LIBS=ON" ".." } try-process
                qw{ msbuild OpenBLAS.sln /property:Configuration=Release } try-process
            ] if
            "lib/RELEASE/openblas.dll" "blas.dll" copy-output-file-as
        ] with-build-directory
    ] with-updated-github-repo ;

: build-openssl-32-dlls ( -- )
    "openssl" "openssl" [
        check-perl
        "ProgramW6432" os-env program-files or
            "NASM/nasm.exe" append-path "nasm.exe" prepend-current-path copy-file
        check-nasm
        check-nmake
        qw{ perl Configure -DOPENSSL_PIC VC-WIN32 /FS } try-process
        have-jom? qw{ jom -j 32 } { "nmake" } ? try-process
        { "libssl-3.dll" "libcrypto-3.dll" } copy-output-files
    ] with-updated-github-repo ;

: build-openssl-64-dlls ( -- )
    "openssl" "openssl" [
        check-perl
        program-files "NASM/nasm.exe" append-path "nasm.exe" prepend-current-path copy-file
        check-nasm
        check-nmake
        qw{ perl Configure -DOPENSSL_PIC VC-WIN64A /FS } try-process
        have-jom? qw{ jom -j 32 } { "nmake" } ? try-process
        { "apps/libssl-3-x64.dll" "apps/libcrypto-3-x64.dll" } copy-output-files
    ] with-updated-github-repo ;

: build-openssl-dlls ( -- )
    32-bit? [ build-openssl-32-dlls ] [ build-openssl-64-dlls ] if ;

: build-cairo-dll ( -- )
    "gitlab.freedesktop.org" "cairo" "cairo" [
        qw{ meson setup --force-fallback-for=freetype2,fontconfig,zlib,expat,expat_dep build } try-process
        "build" prepend-current-path
        [ { "ninja" } try-process ] with-directory
        "." find-dlls copy-output-files
        {
            "gdbus-example-objectmanager.dll"
            "moduletestplugin_a_library.dll"
            "moduletestplugin_a_plugin.dll"
            "moduletestplugin_b_library.dll"
            "moduletestplugin_b_plugin.dll"
            "testmodulea.dll"
            "testmoduleb.dll"
        } delete-output-files
    ] with-updated-gitlab-repo ;

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
            32-bit? [
                qw{ cmake -A Win32 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. } try-process
                qw{ msbuild LibreSSL.sln /m /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. } try-process
                qw{ msbuild LibreSSL.sln /m /property:Configuration=Release } try-process
            ] if
            {
                "crypto/Release/crypto-50.dll"
                "ssl/Release/ssl-53.dll"
                "tls/Release/tls-26.dll"
            } copy-output-files
        ] with-build-directory
    ] with-tar-gz ;

: build-openal-dll ( -- )
    "kcat" "openal-soft" [
        [
            32-bit? [
                {
                    "cmake"
                    "-G" "Visual Studio 17 2022"
                    "-A" "Win32"
                    "-DCMAKE_BUILD_TYPE=Release"
                    "-DBUILD_SHARED_LIBS=ON" ".."
                } try-process
                qw{ msbuild OpenAL.sln /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                {
                    "cmake"
                    "-G" "Visual Studio 17 2022"
                    "-DCMAKE_BUILD_TYPE=Release"
                    "-DBUILD_SHARED_LIBS=ON" ".."
                } try-process
                qw{ msbuild OpenAL.sln /property:Configuration=Release } try-process
            ] if
            "Release/OpenAL32.dll" copy-output-file
        ] with-build-directory
    ] with-updated-github-repo ;

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
            32-bit? [
                qw{ cmake -A Win32  -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON -DPCRE_SUPPORT_LIBZ=OFF -DPCRE_SUPPORT_LIBBZ2=OFF -DPCRE_SUPPORT_LIBREADLINE=OFF .. } try-process
                qw{ msbuild PCRE.sln /m /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON .. } try-process
                qw{ msbuild PCRE.sln /m /property:Configuration=Release } try-process
            ] if
            "Release/pcre.dll" copy-output-file
        ] with-build-directory
    ] with-tar-gz ;

: build-pcre2-dll ( -- )
    "PCRE2Project" "pcre2" [
        [
            32-bit? [
                qw{ cmake -A Win32 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DPCRE2_SUPPORT_UNICODE=ON -DPCRE2_SUPPORT_LIBZ=OFF -DPCRE2_SUPPORT_LIBBZ2=OFF -DPCRE2_SUPPORT_LIBEDIT=OFF -DPCRE2_SUPPORT_LIBREADLINE=OFF .. } try-process
                qw{ msbuild PCRE2.sln /m /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DPCRE_SUPPORT_UTF=ON -DPCRE_SUPPORT_UNICODE_PROPERTIES=ON .. } try-process
                qw{ msbuild PCRE2.sln /m /property:Configuration=Release } try-process
            ] if
            { "Release/pcre2-8.dll" "Release/pcre2-posix.dll" } copy-output-files
        ] with-build-directory
    ] with-updated-github-repo ;

! choco install -y meson winflexbison3
: build-postgres-dll ( -- )
    "postgres" "postgres" [
        "src/tools/msvc/clean.bat" prepend-current-path try-process
        qw{ meson setup build } try-process
        "build" prepend-current-path
        [ { "ninja" } try-process ] with-directory
        "build/src/interfaces/libpq/libpq.dll" copy-output-file
    ] with-updated-github-repo ;

! choco install -y glfw3
: build-raylib-dll ( -- )
    "raysan5" "raylib" [
        [
            32-bit? [
                qw{ cmake -A Win32 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DUSE_EXTERNAL_GLFW=OFF .. } try-process
                qw{ msbuild raylib.sln /m /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DUSE_EXTERNAL_GLFW=OFF .. } try-process
                qw{ msbuild raylib.sln /m /property:Configuration=Release } try-process
            ] if
            "raylib/Release/raylib.dll" copy-output-file
        ] with-build-directory
    ] with-updated-github-repo ;

: build-raygui-dll ( -- )
    "raysan5" "raygui" [
        "src/raygui.h" "src/raygui.c" copy-file
        32-bit? [
            qw{ cl /O2 /I ../raylib/src/ /D_USRDLL /D_WINDLL /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED src/raygui.c /LD /Feraygui.dll /link /LIBPATH ../raylib/build/raylib/Release/raylib.lib /subsystem:windows /machine:x86 } try-process
        ] [
            qw{ cl /O2 /I ../raylib/src/ /D_USRDLL /D_WINDLL /DRAYGUI_IMPLEMENTATION /DBUILD_LIBTYPE_SHARED src/raygui.c /LD /Feraygui.dll /link /LIBPATH ../raylib/build/raylib/Release/raylib.lib /subsystem:windows /machine:x64 } try-process
        ] if
        "raygui.dll" copy-output-file
    ] with-updated-github-repo ;

: build-snappy-dll ( -- )
    "google" "snappy" [
        [
            32-bit? [
                qw{ cmake -A Win32 -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF .. } try-process
                qw{ msbuild Snappy.sln /m /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DSNAPPY_BUILD_TESTS=OFF -DSNAPPY_BUILD_BENCHMARKS=OFF .. } try-process
                qw{ msbuild Snappy.sln /m /property:Configuration=Release } try-process
            ] if
            "Release/snappy.dll" copy-output-file
        ] with-build-directory
    ] with-updated-github-repo ;

: build-sqlite3-dll ( -- )
    "sqlite" "sqlite" [
        qw{ nmake /f Makefile.msc clean } try-process
        qw{ nmake /f Makefile.msc } try-process
        "sqlite3.dll" copy-output-file
    ] with-updated-github-repo ;

: build-yaml-dll ( -- )
    "yaml" "libyaml" [
        [
            32-bit? [
                qw{ cmake -DBUILD_SHARED_LIBS=ON -A Win32 .. } try-process
                qw{ msbuild yaml.sln /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
                qw{ msbuild yaml.sln /property:Configuration=Release } try-process
            ] if

            "Release/yaml.dll" copy-output-file
        ] with-build-directory
    ] with-updated-github-repo ;

: build-zeromq-dll ( -- )
    "zeromq" "libzmq" [
        [
            32-bit? [
                qw{ cmake -DBUILD_SHARED_LIBS=ON -A Win32 .. } try-process
                qw{ msbuild ZeroMQ.sln /property:Configuration=Release /p:Platform=Win32 } try-process
            ] [
                qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
                qw{ msbuild ZeroMQ.sln /property:Configuration=Release } try-process
            ] if
            "bin/Release" find-dlls first "libzmq.dll" copy-output-file-as
        ] with-build-directory
    ] with-updated-github-repo ;

: build-zlib-dll ( -- )
    "madler" "zlib" [
        qw{ nmake /f win32/Makefile.msc clean } try-process
        qw{ nmake /f win32/Makefile.msc } try-process
        "zlib1.dll" copy-output-file
    ] with-updated-github-repo ;

: build-lz4 ( -- )
    "lz4" "lz4" [
        "build/cmake" [
            [
                32-bit? [
                    qw{ cmake -A Win32 -DBUILD_SHARED_LIBS=ON .. } try-process
                    qw{ msbuild LZ4.sln /property:Configuration=Release /p:Platform=Win32 } try-process
                ] [
                    qw{ cmake -DBUILD_SHARED_LIBS=ON .. } try-process
                    qw{ msbuild LZ4.sln /property:Configuration=Release } try-process
                ] if
                "Release/lz4.dll" copy-output-file
            ] with-build-directory
        ] with-directory
    ] with-updated-github-repo ;

: build-zstd-dll ( -- )
    "facebook" "zstd" [
        32-bit? [
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
                -Dlzma=disabled
                -Dzlib=disabled
                build/meson builddir
            } try-process
        ] [
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
        ] if
        "builddir" prepend-current-path
        [
            { "ninja" } try-process
            "lib/zstd-1.dll" copy-output-file
        ] with-directory
    ] with-updated-github-repo ;

! Probably not needed on Windows 10+
: install-windows-redistributable ( -- )
    [
        "https://aka.ms/vs/17/release/vc_redist.x64.exe" download
        qw{ vc_redist.x64.exe /install /passive /norestart } try-process
    ] with-temp-directory ;

: build-windows-dlls ( -- )
    dll-out-directory make-directories
    build-winflexbison
    build-cairo-dll
    build-openssl-dlls
    build-blas
    build-libressl-dlls
    build-fftw-dll
    build-openal-dll
    build-pcre-dll
    build-pcre2-dll
    32-bit? [ build-postgres-dll ] unless
    build-raylib-dll
    build-snappy-dll
    build-sqlite3-dll
    build-yaml-dll
    build-zeromq-dll
    build-zlib-dll
    build-zstd-dll ;
