IN: concurrency.flags.tests
USING: tools.test concurrency.flags kernel threads locals ;

:: flag-test-1 ( -- )
    [let | f [ <flag> ] |
        [ f raise-flag ] "Flag test" spawn drop
        f lower-flag
        f flag-value?
    ] ;

[ f ] [ flag-test-1 ] unit-test

:: flag-test-2 ( -- )
    [let | f [ <flag> ] |
        [ 1000 sleep f raise-flag ] "Flag test" spawn drop
        f lower-flag
        f flag-value?
    ] ;

[ f ] [ flag-test-2 ] unit-test

:: flag-test-3 ( -- )
    [let | f [ <flag> ] |
        f raise-flag
        f flag-value?
    ] ;

[ t ] [ flag-test-3 ] unit-test

:: flag-test-4 ( -- )
    [let | f [ <flag> ] |
        [ f raise-flag ] "Flag test" spawn drop
        f wait-for-flag
        f flag-value?
    ] ;

[ t ] [ flag-test-4 ] unit-test

:: flag-test-5 ( -- )
    [let | f [ <flag> ] |
        [ 1000 sleep f raise-flag ] "Flag test" spawn drop
        f wait-for-flag
        f flag-value?
    ] ;

[ t ] [ flag-test-5 ] unit-test
