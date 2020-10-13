! Copyright (C) 2013 Björn Lindqvist, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license
USING: alien.libraries.finder arrays assocs
combinators.short-circuit environment fry io io.encodings.utf8
io.launcher kernel locals make sequences sets splitting system
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
    "/sbin/ldconfig -p" utf8 [ lines ] with-process-reader*
    2drop [ f ] [ rest parse-ldconfig-lines ] if-empty ;

: ldconfig-arch ( -- str )
    mach-map cpu of { "libc6" } or ;

: name-matches? ( lib triple -- ? )
    first swap ?head [ ?first CHAR: . = ] [ drop f ] if ;

: arch-matches? ( lib triple -- ? )
    [ drop ldconfig-arch ] [ second swap subset? ] bi* ;

: ldconfig-matches? ( lib triple -- ? )
    { [ name-matches? ] [ arch-matches? ] } 2&& ;

: find-ldconfig ( name -- path/f )
    "lib" prepend load-ldconfig-cache
    [ ldconfig-matches? ] with find nip ?last ;

:: find-ld ( name -- path/f )
    "LD_LIBRARY_PATH" os-env [
        [
            "ld" , "-t" , ":" split [ "-L" , , ] each
            "-o" , "/dev/null" , "-l" name append ,
        ] { } make utf8 [ lines ] with-process-reader* 2drop
        "lib" name append '[ _ swap subseq? ] find nip
    ] [ f ] if* ;

PRIVATE>

M: linux find-library*
    { [ find-ldconfig ] [ find-ld ] } 1|| ;
