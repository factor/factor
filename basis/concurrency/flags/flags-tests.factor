USING: tools.test concurrency.flags concurrency.combinators
kernel threads accessors calendar ;
IN: concurrency.flags.tests

:: flag-test-1 ( -- val )
    <flag> :> f
    [ f raise-flag ] "Flag test" spawn drop
    f lower-flag
    f value>> ;

{ f } [ flag-test-1 ] unit-test

:: flag-test-2 ( -- ? )
    <flag> :> f
    [ 1 seconds sleep f raise-flag ] "Flag test" spawn drop
    f lower-flag
    f value>> ;

{ f } [ flag-test-2 ] unit-test

:: flag-test-3 ( -- val )
    <flag> :> f
    f raise-flag
    f value>> ;

{ t } [ flag-test-3 ] unit-test

:: flag-test-4 ( -- val )
    <flag> :> f
    [ f raise-flag ] "Flag test" spawn drop
    f wait-for-flag
    f value>> ;

{ t } [ flag-test-4 ] unit-test

:: flag-test-5 ( -- val )
    <flag> :> f
    [ 1 seconds sleep f raise-flag ] "Flag test" spawn drop
    f wait-for-flag
    f value>> ;

{ t } [ flag-test-5 ] unit-test

{ } [
    { 1 2 } <flag>
    [ [ 1 seconds sleep raise-flag ] curry "Flag test" spawn drop ]
    [ [ wait-for-flag drop ] curry parallel-each ] bi
] unit-test
