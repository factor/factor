! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.promises models tools.walker kernel
sequences concurrency.messaging locals continuations
threads namespaces namespaces.private ;
IN: tools.walker.debug

:: test-walker ( quot -- data )
    [let | p [ <promise> ]
           s [ f <model> ]
           c [ f <model> ] |
        [
            H{ } clone >n
            [ s c start-walker-thread p fulfill ] new-walker-hook set
            [ drop ] show-walker-hook set

            break

            quot call
        ] "Walker test" spawn drop

        step-into-all
        p ?promise
        send-synchronous drop

        detach
        p ?promise
        send-synchronous drop

        c model-value continuation-data
    ] ;
