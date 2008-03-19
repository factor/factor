! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: concurrency.promises models tools.walker kernel
sequences concurrency.messaging locals continuations
threads namespaces namespaces.private assocs ;
IN: tools.walker.debug

:: test-walker ( quot -- data )
    [let | p [ <promise> ] |
        [
            H{ } clone >n

            [
                p promise-fulfilled?
                [ drop ] [ p fulfill ] if
                2drop
            ] show-walker-hook set

            break

            quot call
        ] "Walker test" spawn drop

        step-into-all
        p ?promise
        send-synchronous drop

        p ?promise
        thread-variables walker-continuation swap at
        model-value continuation-data
    ] ;
