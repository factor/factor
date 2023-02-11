! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors concurrency.mailboxes kernel ;
IN: concurrency.promises

TUPLE: promise mailbox ;

: <promise> ( -- promise )
    <mailbox> promise boa ;

: promise-fulfilled? ( promise -- ? )
    mailbox>> mailbox-empty? not ;

ERROR: promise-already-fulfilled promise ;

: fulfill ( value promise -- )
    dup promise-fulfilled? [
        promise-already-fulfilled
    ] [
        mailbox>> mailbox-put
    ] if ;

: ?promise-timeout ( promise timeout -- result )
    [ mailbox>> ] dip block-if-empty mailbox-peek ;

: ?promise ( promise -- result )
    f ?promise-timeout ;
