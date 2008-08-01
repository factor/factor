! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.promises concurrency.mailboxes kernel arrays
continuations ;
IN: concurrency.futures

: future ( quot -- future )
    <promise> [
        [ [ >r call r> fulfill ] 2curry "Future" ] keep
        promise-mailbox spawn-linked-to drop
    ] keep ; inline

: ?future-timeout ( future timeout -- value )
    ?promise-timeout ?linked ;

: ?future ( future -- value )
    ?promise ?linked ;
