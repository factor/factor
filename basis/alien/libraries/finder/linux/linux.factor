! Copyright (C) 2013 Björn Lindqvist
! See http://factorcode.org/license.txt for BSD license

USING: alien.libraries alien.libraries.finder assocs io
io.encodings.utf8 io.launcher kernel sequences splitting system
;

IN: alien.libraries.finder.linux

<PRIVATE

CONSTANT: mach-map {
    { ppc.64 "libc6,64bit" }
    { x86.32 "libc6,x86-32" }
    { x86.64 "libc6,x86-64" }
}

: ldconfig-cache ( -- seq )
    "/sbin/ldconfig -p" utf8 [ lines ] with-process-reader rest
    [ "=>" "" replace "\t " split harvest ] map ;

: ldconfig-filter ( -- str )
    mach-map cpu of "libc6" or "(" ")" surround ;

: ldconfig-matches? ( lib this-lib this-arch -- ? )
    [ start 0 = ] [ ldconfig-filter = ] bi* and ;

: ldconfig-find-soname ( lib -- seq )
    ldconfig-cache [ first2 ldconfig-matches? ] with filter [ first ] map ;

PRIVATE>

M: linux find-library
    "lib" ".so" surround ldconfig-find-soname
    [ dlopen dll-valid? ] map-find nip ;

