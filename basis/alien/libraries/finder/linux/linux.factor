! Copyright (C) 2013 Björn Lindqvist, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license
USING: alien.libraries alien.libraries.finder arrays assocs
combinators.short-circuit io io.encodings.utf8 io.files
io.files.info io.launcher kernel sequences sets splitting system
unicode.categories ;
IN: alien.libraries.finder.linux

<PRIVATE

CONSTANT: mach-map {
    { ppc.64 { "libc6" "64bit" } }
    { x86.32 { "libc6" "x32" } }
    { x86.64 { "libc6" "x86-64" } }
}

: parse-ldconfig-lines ( string -- triple )
    [
        "=>" split1 [ [ blank? ] trim ] bi@
        [ " " split1 [ "()" in? ] trim "," split ] dip 3array
    ] map ;

: load-ldconfig-cache ( -- seq )
    "/sbin/ldconfig -p" utf8 [ lines ] with-process-reader
    rest parse-ldconfig-lines ;

: ldconfig-arch ( -- str )
    mach-map cpu of { "libc6" } or ;

: ldconfig-matches? ( lib triple -- ? )
    { [ first head? ] [ nip second ldconfig-arch subset? ] } 2&& ;

: ldconfig-find-soname ( lib -- seq )
    load-ldconfig-cache [ ldconfig-matches? ] with filter [ third ] map ;

PRIVATE>

M: linux find-library
    "lib" ".so" surround ldconfig-find-soname [
        { [ exists? ] [ file-info regular-file? ] } 1&&
    ] map-find nip ;
