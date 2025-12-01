! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors boxes concurrency.promises kernel threads ;
IN: concurrency.futures

: future ( quot -- future )
    <promise> [
        [ '[ init-namestack @ _ fulfill ] "Future" ] keep
        spawn-linked-to drop
    ] keep ; inline

: ?future-timeout ( future timeout -- value )
    ?promise-timeout ?linked ;

: ?future ( future -- value )
    ?promise ?linked ;
