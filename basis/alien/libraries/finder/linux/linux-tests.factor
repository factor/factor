USING: alien.libraries.finder alien.libraries.finder.linux.private
arrays environment io.directories io.encodings.utf8 io.files
io.pathnames kernel sequences tools.test ;
IN: alien.libraries.finder.linux.tests

! Versioned basenames from #1099, without depending on SDL being installed.
{ t t t } [
    "libSDL" "libSDL-1.2.so.0" library-name-matches?
    "libSDL-1" "libSDL-1.2.so.0" library-name-matches?
    "libSDL-1.2" "libSDL-1.2.so.0" library-name-matches?
] unit-test

{ t t f f f f f f } [
    "libSDL" "libSDL.so" library-name-matches?
    "libSDL" "libSDL.so.0" library-name-matches?
    "libSDL" "libSDL2.so.0" library-name-matches?
    "libSDL" "libSDL_image.so.0" library-name-matches?
    "libSDL" "libSDL-image.so.0" library-name-matches?
    "libSDL-1" "libSDL-10.so.0" library-name-matches?
    "libSDL" "libSDL-1..2.so.0" library-name-matches?
    "libSDL" "libSDL-1.2.software" library-name-matches?
] unit-test

! Exercise real ELF filtering and directory discovery without ldconfig.
{ t t t t } [ [
    "m" find-library "libfactor-finder-version-1.2.so.0" copy-file
    "." absolute-path "LD_LIBRARY_PATH" [
        "libfactor-finder-version" find-in-library-directories
        file-name "libfactor-finder-version-1.2.so.0" =
        "factor-finder-version-1" find-library*
        file-name "libfactor-finder-version-1.2.so.0" =
        "factor-finder-version-1.2" find-library*
        file-name "libfactor-finder-version-1.2.so.0" =
        "libfactor-finder-version-1.2.so.0"
        "libfactor-finder-version.so.0" copy-file
        "libfactor-finder-version" find-in-library-directories
        file-name "libfactor-finder-version.so.0" =
    ] with-os-env
] with-test-directory ] unit-test

{ f } [ B{ } native-elf-header? ] unit-test
{ f } [ B{ 127 69 76 70 } native-elf-header? ] unit-test
{ f } [ "/* GNU ld script: not a loadable ELF object */" native-elf-header? ] unit-test
{ t } [
    "/factor/nonexistent/runtime/lib" "LD_LIBRARY_PATH"
    [ library-search-directories first "/factor/nonexistent/runtime/lib" = ] with-os-env
] unit-test
{ t } [
    "" "LD_LIBRARY_PATH" [ library-search-directories first "." = ] with-os-env
] unit-test

{ f } [
    "/factor/nonexistent/runtime/lib" "LD_LIBRARY_PATH" [
        "libfactor-finder-missing-directory-regression" find-in-library-directories
    ] with-os-env
] unit-test

{ t } [ "m" find-library "libm.so" subseq-of? ] unit-test
{ t } [ "c" find-library "libc.so" subseq-of? ] unit-test

! A wrapper-provided text cache works without ldconfig. Architecture labels
! are only hints: validate the actual ELF, including for ARM64 and RISC-V.
{ t } [ [
    "m" find-library "libfactor-nix-cache.so.1" copy-file
    "libfactor-nix-cache.so.1" absolute-path
    " libfactor-nix-cache.so.1 (libc6,x86-64) => " prepend
    "a wrapper cache header\n" prepend
    "cache.txt" utf8 set-file-contents
    "cache.txt" absolute-path "FACTOR_LD_SO_CACHE" [
        "factor-nix-cache" find-library file-name
        "libfactor-nix-cache.so.1" =
    ] with-os-env
] with-test-directory ] unit-test

{ { } } [ [
    "an empty cache\n" "cache.txt" utf8 set-file-contents
    "cache.txt" absolute-path "FACTOR_LD_SO_CACHE"
    [ load-ldconfig-cache ] with-os-env
] with-test-directory ] unit-test
