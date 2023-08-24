USING: tools.test concurrency.exchangers
concurrency.count-downs concurrency.promises kernel
threads ;
FROM: sequences => 3append ;
IN: concurrency.exchangers.tests

:: exchanger-test ( -- string )
    <exchanger> :> ex
    2 <count-down> :> c
    f :> v1!
    f :> v2!
    <promise> :> pr

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

    pr ?promise ;

{ "Hello world, Goodbye world" } [ exchanger-test ] unit-test
