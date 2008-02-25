USING: compiler continuations io kernel math namespaces
prettyprint quotations random sequences vectors
compile-call ;
USING: random-tester.databank random-tester.safe-words ;
IN: random-tester

SYMBOL: errored
SYMBOL: before
SYMBOL: after
SYMBOL: quot
TUPLE: random-tester-error ;

: setup-test ( #data #code -- data... quot )
    #! Variable stack effect
    >r [ databank random ] times r>
    [ drop \ safe-words get random ] map >quotation ;

: test-compiler ! ( data... quot -- ... )
    errored off
    dup quot set
    datastack 1 head* before set
    [ call ] [ drop ] recover
    datastack after set
    clear
    before get [ ] each
    quot get [ compile-call ] [ errored on ] recover ;

: do-test ! ( data... quot -- )
    .s flush test-compiler
    errored get [
        datastack after get 2dup = [
            2drop
        ] [
            [ . ] each
            "--" print
            [ . ] each
            quot get .
            random-tester-error construct-empty throw
        ] if
    ] unless clear ;

: random-test1 ( #data #code -- )
    setup-test do-test ;

: random-test2 ( -- )
    3 2 setup-test do-test ;
