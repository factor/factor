! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.promises models tools.walker kernel
sequences concurrency.messaging locals ;
IN: tools.walker.debug

:: test-walker | quot |
    [let | p [ <promise> ]
           s [ f <model> ]
           c [ f <model> ] |
        [ s c start-walker-thread p fulfill break ]
        quot compose

        step-into-all
        p ?promise
        send-synchronous drop

        c model-value continuation-data
    ] ;
