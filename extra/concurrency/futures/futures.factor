! Copyright (C) 2005, 2008 Chris Double, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: concurrency.futures

: future ( quot -- future )
    <promise> [
        [
            >r
            [ t 2array ] compose
            [ <linked> f 2array ] recover
            r> fulfill
        ] 2curry "Future" spawn drop
    ] keep ; inline

: ?future-timeout ( future timeout -- value )
    ?promise-timeout first2 [ rethrow ] unless ;

: ?future ( future -- value )
    f ?future-timeout ;

: parallel-map ( seq quot -- newseq )
    [ curry future ] curry map [ ?future ] map ;

: parallel-each ( seq quot -- )
    [ f ] compose parallel-map drop ;
