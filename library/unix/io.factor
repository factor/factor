! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io-internals
USING: errors kernel math strings ;

: file-mode OCT: 0600 ;

: io-error ( n -- ) 0 < [ errno strerror throw ] when ;

: open-read ( path -- fd )
    O_RDONLY file-mode sys-open dup io-error ;

: open-write ( path -- fd )
    O_WRONLY O_CREAT bitor O_TRUNC bitor file-mode sys-open
    dup io-error ;

: read-step ( fd buffer -- ? )
    tuck dup buffer@ swap buffer-capacity sys-read
    dup 0 >= [
        swap buffer-inc-fill t
    ] [
        2drop f
    ] ifte ;

: read-count-step ( sbuf count buffer -- ? )
    2dup buffer-fill <= [
        buffer> swap sbuf-append t
    ] [
        buffer>> nip swap sbuf-append f
    ] ifte ;
