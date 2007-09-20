USING: locals math sequences tools.test hashtables words kernel
namespaces ;
IN: temporary

:: foo | a b | a a ;

[ 1 1 ] [ 1 2 foo ] unit-test

:: add-test | a b | a b + ;

[ 3 ] [ 1 2 add-test ] unit-test

:: sub-test | a b | a b - ;

[ -1 ] [ 1 2 sub-test ] unit-test

:: map-test | a b | a [ b + ] map ;

[ { 5 6 7 } ] [ { 1 2 3 } 4 map-test ] unit-test

:: map-test-2 | seq inc | seq [| elt | elt inc + ] map ;

[ { 5 6 7 } ] [ { 1 2 3 } 4 map-test-2 ] unit-test

:: let-test | c |
    [let | a [ 1 ] b [ 2 ] | a b + c + ] ;

[ 7 ] [ 4 let-test ] unit-test

:: let-test-2 | |
    [let | a [ ] | [let | b [ a ] | a ] ] ;

[ 3 ] [ 3 let-test-2 ] unit-test

:: let-test-3 | |
    [let | a [ ] | [let | b [ [ a ] ] | [let | a [ 3 ] | b ] ] ] ;

[ -1 ] [ -1 let-test-3 call ] unit-test

[ 5 ] [
    [let | a [ 3 ] | [wlet | func [ a + ] | 2 func ] ]
    with-locals
] unit-test

:: wlet-test-2 | a b |
    [wlet | add-b [ b + ] |
        a [ add-b ] map ] ;


[ { 4 5 6 } ] [ { 2 3 4 } 2 wlet-test-2 ] unit-test
    
:: wlet-test-3 | a |
    [wlet | add-a [ a + ] | [ add-a ] ]
    [let | a [ 3 ] | a swap call ] ;

[ 5 ] [ 2 wlet-test-3 ] unit-test

:: wlet-test-4 | a |
    [wlet | sub-a [| b | b a - ] |
        3 sub-a ] ;

[ -7 ] [ 10 wlet-test-4 ] unit-test

:: write-test-1 | n! |
    [| i | n i + dup n! ] ;

0 write-test-1 "q" set

[ 1 ] [ 1 "q" get call ] unit-test

[ 2 ] [ 1 "q" get call ] unit-test

[ 3 ] [ 1 "q" get call ] unit-test

[ 5 ] [ 2 "q" get call ] unit-test

:: write-test-2 | |
    [let | n! [ 0 ] |
        [| i | n i + dup n! ] ] ;

write-test-2 "q" set

[ 1 ] [ 1 "q" get call ] unit-test

[ 2 ] [ 1 "q" get call ] unit-test

[ 3 ] [ 1 "q" get call ] unit-test

[ 5 ] [ 2 "q" get call ] unit-test

[ 10 20 ]
[
    20 10 [| a! | [| b! | a b ] ] with-locals call call
] unit-test

:: write-test-3 | a! | [| b | b a! ] ;

[ ] [ 1 2 write-test-3 call ] unit-test

:: write-test-4 | x! | [ [let | y! [ 0 ] | f x! ] ] ;

[ ] [ 5 write-test-4 drop ] unit-test

SYMBOL: a

:: use-test | a b c |
    USE: kernel
    ;

[ t ] [ a symbol? ] unit-test
