IN: concurrency.exchangers.tests
USING: sequences tools.test concurrency.exchangers
concurrency.count-downs concurrency.promises locals kernel
threads ;

:: exchanger-test ( -- string )
    [let |
        ex [ <exchanger> ]
        c [ 2 <count-down> ]
        v1! [ f ]
        v2! [ f ]
        pr [ <promise> ] |

        [
            c await
            v1 ", " v2 3append pr fulfill
        ] "Awaiter" spawn drop

        [
            "Goodbye world" ex exchange v1! c count-down
        ] "Exchanger 1" spawn drop

        [
            "Hello world" ex exchange v2! c count-down
        ] "Exchanger 2" spawn drop

        pr ?promise
    ] ;

[ "Hello world, Goodbye world" ] [ exchanger-test ] unit-test
