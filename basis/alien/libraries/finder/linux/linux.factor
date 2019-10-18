! Copyright (C) 2013 Björn Lindqvist, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license
USING: alien.libraries.finder arrays assocs
combinators.short-circuit io io.encodings.utf8 io.files
io.files.info io.launcher kernel sequences sets splitting system
unicode ;
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
        [
            " " split1 [ "()" in? ] trim "," split
            [ [ blank? ] trim ] map
            [ ": Linux" swap subseq? ] reject
        ] dip 3array
    ] map ;

: load-ldconfig-cache ( -- seq )
    "/sbin/ldconfig -p" utf8 [ lines ] with-process-reader
    rest parse-ldconfig-lines ;

: ldconfig-arch ( -- str )
    mach-map cpu of { "libc6" } or ;

: name-matches? ( lib triple -- ? )
    first swap ?head [ ?first CHAR: . = ] [ drop f ] if ;

: arch-matches? ( lib triple -- ? )
    [ drop ldconfig-arch ] [ second swap subset? ] bi* ;

: ldconfig-matches? ( lib triple -- ? )
    { [ name-matches? ] [ arch-matches? ] } 2&& ;

PRIVATE>

M: linux find-library*
    "lib" prepend load-ldconfig-cache
    [ ldconfig-matches? ] with find nip ?first ;
