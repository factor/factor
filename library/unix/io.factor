! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: errors kernel math sequences strings ;

: file-mode OCT: 0600 ;

: io-error ( n -- ) 0 < [ errno strerror throw ] when ;

: open-read ( path -- fd )
    O_RDONLY file-mode sys-open dup io-error ;

: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode sys-open
    dup io-error ;

: read-step ( fd buffer -- ? )
    tuck dup buffer-end swap buffer-capacity sys-read
    dup 0 >= [ swap n>buffer t ] [ 2drop f ] ifte ;

TUPLE: reader line buffer ready? ;

C: reader ( buffer -- reader )
    [ set-reader-buffer ] keep ;

: >reader< ( reader -- line buffer )
    dup reader-line swap reader-buffer ;

: pending-error ( reader -- ) drop ;

: read-line-loop ( line buffer -- ? )
    dup buffer-length 0 = [
        2drop f
    ] [
        dup buffer-peek dup CHAR: \n = [
            3drop t
        ] [
            1 pick buffer-consume pick sbuf-append
            read-line-loop
        ] ifte
    ] ifte ;

: read-line-step ( reader -- ? ) >reader< read-line-loop ;

: init-reader ( count reader -- ) >r <sbuf> r> set-reader-line ;

: prepare-line ( reader -- ? )
    80 over init-reader dup read-line-step
    [ swap set-reader-ready? ] keep ;

: can-read-line? ( reader -- ? )
    dup pending-error
    dup reader-ready? [ drop t ] [ prepare-line ] ifte ;

: reader-eof ( reader -- )
    dup reader-line dup [
        length 0 = [ f over set-reader-line ] when
    ] [
        drop
    ] ifte  t swap set-reader-ready? ;

GENERIC: refill* ( reader -- )
M: reader refill* drop ;

: refill ( reader -- )
    dup reader-buffer buffer-length 0 = [
        refill*
    ] [
        drop
    ] ifte ;

: reader-eof? ( reader -- ? ) reader-buffer buffer-fill 0 = ;

: read-line-task ( reader -- ? )
    dup refill dup reader-eof? [
        reader-eof t
    ] [
        read-line-step
    ] ifte ;

: read-count-step ( count reader -- ? )
    >reader< swapd >r over length - r> 2dup buffer-fill <= [
        buffer> swap sbuf-append t
    ] [
        buffer>> nip swap sbuf-append f
    ] ifte ;

: can-read-count? ( count reader -- ? )
    dup pending-error
    2dup reader-line length >= [
        2drop t
    ] [
        2dup init-reader read-count-step
    ] ifte ;

: read-count-task ( count reader -- ? )
    dup refill dup reader-eof? [
        nip reader-eof t
    ] [
        read-count-step
    ] ifte ;

: pop-line ( reader -- str )
    dup reader-line sbuf>string >r
    f over set-reader-line
    f swap set-reader-ready? r> ;

: read-fin ( reader -- str )
    dup pending-error  dup reader-ready? [
        pop-line
    ] [
        "reader not ready" throw
    ] ifte ;
