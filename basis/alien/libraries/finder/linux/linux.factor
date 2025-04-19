! Copyright (C) 2013 Björn Lindqvist, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license
USING: accessors alien.libraries.finder arrays assocs
combinators.short-circuit environment io io.encodings.utf8
io.launcher kernel make sequences sets splitting system
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
        "=>" split1 [ [ unicode:blank? ] trim ] bi@
        [
            " " split1 [ "()" in? ] trim "," split
            [ [ unicode:blank? ] trim ] map
            [ ": Linux" subseq-of? ] reject
        ] dip 3array
    ] map ;

: load-ldconfig-cache ( -- seq )
    "/sbin/ldconfig -p" utf8 [ read-lines ] with-process-reader*
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
    load-ldconfig-cache
    [ ldconfig-matches? ] with find nip ?last ;

:: find-ld ( name -- path/f )
    name <process>
        [
            "ld" , "-t" ,
            "LD_LIBRARY_PATH" os-env ":" split [ "-L" , , ] each
            cpu x86.64? "-melf_x86_64" "-melf_i386" ? ,
            "-o" , "/dev/null" , "-l" name append ,
        ] { } make >>command
        +closed+ >>stderr
    utf8 [ read-lines ] with-process-reader* 2drop
    [ subseq? ] with find nip ;

PRIVATE>

M: linux find-library*
    { [ find-ldconfig ] [ find-ld ] } 1|| ;
