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

: read-count-step ( sbuf count buffer -- ? )
    >r over length - r> 2dup buffer-fill <= [
        buffer> swap sbuf-append t
    ] [
        buffer>> nip swap sbuf-append f
    ] ifte ;

: read-line-step ( line buffer -- ? )
    dup buffer-length 0 = [
        2drop f
    ] [
        dup buffer-peek dup CHAR: \n = [
            3drop t
        ] [
            1 pick buffer-consume pick sbuf-append
            read-line-step
        ] ifte
    ] ifte ;

TUPLE: reader line buffer ready? ;

C: reader ( buffer -- reader )
    [ set-reader-buffer ] keep ;

: init-reader ( reader -- ) 80 <sbuf> swap set-reader-line ;

: prepare-line ( reader -- ? )
    dup init-reader
    dup reader-line over reader-buffer read-line-step
    [ swap set-reader-ready? ] keep ;

: can-read-line? ( reader -- ? )
    dup reader-ready? [ drop t ] [ prepare-line ] ifte ;

: reader-eof ( reader -- )
    dup reader-line dup [
        length 0 = [ f swap set-reader-line ] when
    ] [
        drop
    ] ifte  t swap set-reader-ready? ;
