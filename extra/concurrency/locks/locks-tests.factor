IN: temporary
USING: tools.test concurrency.locks concurrency.count-downs
locals kernel threads sequences ;

:: lock-test-0 | |
    [let | v [ V{ } clone ]
           c [ 2 <count-down> ] |

           [
               yield
               1 v push
               yield
               2 v push
               c count-down
           ] "Lock test 1" spawn drop

           [
               yield
               3 v push
               yield
               4 v push
               c count-down
           ] "Lock test 2" spawn drop

           c await
           v
    ] ;

:: lock-test-1 | |
    [let | v [ V{ } clone ]
           l [ <lock> ]
           c [ 2 <count-down> ] |

           [
               l f [
                   yield
                   1 v push
                   yield
                   2 v push
               ] with-lock
               c count-down
           ] "Lock test 1" spawn drop

           [
               l f [
                   yield
                   3 v push
                   yield
                   4 v push
               ] with-lock
               c count-down
           ] "Lock test 2" spawn drop

           c await
           v
    ] ;

[ V{ 1 3 2 4 } ] [ lock-test-0 ] unit-test
[ V{ 1 2 3 4 } ] [ lock-test-1 ] unit-test

[ 3 ] [
    <reentrant-lock> dup f [
        f [
            3
        ] with-lock
    ] with-lock
] unit-test

[ ] [ <rw-lock> drop ] unit-test

[ ] [ <rw-lock> f [ ] with-read-lock ] unit-test

[ ] [ <rw-lock> dup f [ f [ ] with-read-lock ] with-read-lock ] unit-test

[ ] [ <rw-lock> f [ ] with-write-lock ] unit-test

[ ] [ <rw-lock> dup f [ f [ ] with-write-lock ] with-write-lock ] unit-test

[ ] [ <rw-lock> dup f [ f [ ] with-read-lock ] with-write-lock ] unit-test

:: rw-lock-test-1 | |
    [let | l [ <rw-lock> ]
           c [ 1 <count-down> ]
           c' [ 1 <count-down> ]
           c'' [ 4 <count-down> ]
           v [ V{ } clone ] |

           [
               l f [
                   1 v push
                   c count-down
                   yield
                   3 v push
               ] with-read-lock
               c'' count-down
           ] "R/W lock test 1" spawn drop

           [
               c await
               l f [
                   4 v push
                   1000 sleep
                   5 v push
               ] with-write-lock
               c'' count-down
           ] "R/W lock test 2" spawn drop

           [
               c await
               l f [
                   2 v push
                   c' count-down
               ] with-read-lock
               c'' count-down
           ] "R/W lock test 4" spawn drop

           [
               c' await
               l f [
                   6 v push
               ] with-write-lock
               c'' count-down
           ] "R/W lock test 5" spawn drop

           c'' await
           v
    ] ;

[ V{ 1 2 3 4 5 6 } ] [ rw-lock-test-1 ] unit-test

:: rw-lock-test-2 | |
    [let | l [ <rw-lock> ]
           c [ 1 <count-down> ]
           c' [ 2 <count-down> ]
           v [ V{ } clone ] |

           [
               l f [
                   1 v push
                   c count-down
                   1000 sleep
                   2 v push
               ] with-write-lock
               c' count-down
           ] "R/W lock test 1" spawn drop

           [
               c await
               l f [
                   3 v push
               ] with-read-lock
               c' count-down
           ] "R/W lock test 2" spawn drop

           c' await
           v
    ] ;

[ V{ 1 2 3 } ] [ rw-lock-test-2 ] unit-test
