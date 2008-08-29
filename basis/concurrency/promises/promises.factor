! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes kernel continuations ;
IN: concurrency.promises

TUPLE: promise mailbox ;

: <promise> ( -- promise )
    <mailbox> promise boa ;

: promise-fulfilled? ( promise -- ? )
    mailbox>> mailbox-empty? not ;

: fulfill ( value promise -- )
    dup promise-fulfilled? [ 
        "Promise already fulfilled" throw
    ] [
        mailbox>> mailbox-put
    ] if ;

: ?promise-timeout ( promise timeout -- result )
    >r mailbox>> r> block-if-empty mailbox-peek ;

: ?promise ( promise -- result )
    f ?promise-timeout ;
