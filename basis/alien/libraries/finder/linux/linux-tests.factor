USING: alien.libraries.finder alien.libraries.finder.linux.private
environment kernel sequences tools.test ;
IN: alien.libraries.finder.linux.tests

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
