! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: concurrency.promises

TUPLE: promise mailbox ;

: <promise> ( -- promise )
    <mailbox> promise construct-boa ;

: promise-fulfilled? ( promise -- ? )
    promise-mailbox mailbox-empty? not ;

: fulfill ( value promise -- )
    dup promise-fulfilled? [ 
        "Promise already fulfilled" throw
    ] [
        promise-mailbox mailbox-put
    ] if ;

: ?promise-timeout ( promise timeout -- result )
    >r promise-mailbox r> block-if-empty mailbox-peek ;

: ?promise ( promise -- result )
    f ?promise-timeout ;
