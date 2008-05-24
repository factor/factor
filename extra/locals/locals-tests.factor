USING: locals math sequences tools.test hashtables words kernel
namespaces arrays strings prettyprint io.streams.string parser
accessors ;
IN: locals.tests

:: foo ( a b -- a a ) a a ;

[ 1 1 ] [ 1 2 foo ] unit-test

:: add-test ( a b -- c ) a b + ;

[ 3 ] [ 1 2 add-test ] unit-test

:: sub-test ( a b -- c ) a b - ;

[ -1 ] [ 1 2 sub-test ] unit-test

:: map-test ( a b -- seq ) a [ b + ] map ;

[ { 5 6 7 } ] [ { 1 2 3 } 4 map-test ] unit-test

:: map-test-2 ( seq inc -- seq ) seq [| elt | elt inc + ] map ;

[ { 5 6 7 } ] [ { 1 2 3 } 4 map-test-2 ] unit-test

:: let-test ( c -- d )
    [let | a [ 1 ] b [ 2 ] | a b + c + ] ;

[ 7 ] [ 4 let-test ] unit-test

:: let-test-2 ( a -- a )
    a [let | a [ ] | [let | b [ a ] | a ] ] ;

[ 3 ] [ 3 let-test-2 ] unit-test

:: let-test-3 ( a -- a )
    a [let | a [ ] | [let | b [ [ a ] ] | [let | a [ 3 ] | b ] ] ] ;

:: let-test-4 ( a -- b )
    a [let | a [ 1 ] b [ ] | a b 2array ] ;

[ { 1 2 } ] [ 2 let-test-4 ] unit-test

:: let-test-5 ( a -- b )
    a [let | a [ ] b [ ] | a b 2array ] ;

[ { 2 1 } ] [ 1 2 let-test-5 ] unit-test

:: let-test-6 ( a -- b )
    a [let | a [ ] b [ 1 ] | a b 2array ] ;

[ { 2 1 } ] [ 2 let-test-6 ] unit-test

[ -1 ] [ -1 let-test-3 call ] unit-test

[ 5 ] [
    [let | a [ 3 ] | [wlet | func [ a + ] | 2 func ] ]
] unit-test

:: wlet-test-2 ( a b -- seq )
    [wlet | add-b [ b + ] |
        a [ add-b ] map ] ;


[ { 4 5 6 } ] [ { 2 3 4 } 2 wlet-test-2 ] unit-test
    
:: wlet-test-3 ( a -- b )
    [wlet | add-a [ a + ] | [ add-a ] ]
    [let | a [ 3 ] | a swap call ] ;

[ 5 ] [ 2 wlet-test-3 ] unit-test

:: wlet-test-4 ( a -- b )
    [wlet | sub-a [| b | b a - ] |
        3 sub-a ] ;

[ -7 ] [ 10 wlet-test-4 ] unit-test

:: write-test-1 ( n! -- q )
    [| i | n i + dup n! ] ;

0 write-test-1 "q" set

{ 1 1 } "q" get must-infer-as

[ 1 ] [ 1 "q" get call ] unit-test

[ 2 ] [ 1 "q" get call ] unit-test

[ 3 ] [ 1 "q" get call ] unit-test

[ 5 ] [ 2 "q" get call ] unit-test

:: write-test-2 ( -- q )
    [let | n! [ 0 ] |
        [| i | n i + dup n! ] ] ;

write-test-2 "q" set

[ 1 ] [ 1 "q" get call ] unit-test

[ 2 ] [ 1 "q" get call ] unit-test

[ 3 ] [ 1 "q" get call ] unit-test

[ 5 ] [ 2 "q" get call ] unit-test

[ 10 20 ]
[
    20 10 [| a! | [| b! | a b ] ] call call
] unit-test

:: write-test-3 ( a! -- q ) [| b | b a! ] ;

[ ] [ 1 2 write-test-3 call ] unit-test

:: write-test-4 ( x! -- q ) [ [let | y! [ 0 ] | f x! ] ] ;

[ ] [ 5 write-test-4 drop ] unit-test

! Not really a write test; just enforcing consistency
:: write-test-5 ( x -- y )
    [wlet | fun! [ x + ] | 5 fun! ] ;

[ 9 ] [ 4 write-test-5 ] unit-test

SYMBOL: a

:: use-test ( a b c -- a b c )
    USE: kernel ;

[ t ] [ a symbol? ] unit-test

:: let-let-test ( n -- n ) [let | n [ n 3 + ] | n ] ;

[ 13 ] [ 10 let-let-test ] unit-test

GENERIC: lambda-generic ( a b -- c )

GENERIC# lambda-generic-1 1 ( a b -- c )

M:: integer lambda-generic-1 ( a b -- c ) a b * ;

M:: string lambda-generic-1 ( a b -- c )
    a b CHAR: x <string> lambda-generic ;

M:: integer lambda-generic ( a b -- c ) a b lambda-generic-1 ;

GENERIC# lambda-generic-2 1 ( a b -- c )

M:: integer lambda-generic-2 ( a b -- c )
    a CHAR: x <string> b lambda-generic ;

M:: string lambda-generic-2 ( a b -- c ) a b append ;

M:: string lambda-generic ( a b -- c ) a b lambda-generic-2 ;

[ 10 ] [ 5 2 lambda-generic ] unit-test

[ "abab" ] [ "aba" "b" lambda-generic ] unit-test

[ "abaxxx" ] [ "aba" 3 lambda-generic ] unit-test

[ "xaba" ] [ 1 "aba" lambda-generic ] unit-test

[ ] [ \ lambda-generic-1 see ] unit-test

[ ] [ \ lambda-generic-2 see ] unit-test

[ ] [ \ lambda-generic see ] unit-test

:: unparse-test-1 ( a -- ) [let | a! [ ] | ] ;

[ "[let | a! [ ] | ]" ] [
    \ unparse-test-1 "lambda" word-prop body>> first unparse
] unit-test

:: unparse-test-2 ( -- ) [wlet | a! [ ] | ] ;

[ "[wlet | a! [ ] | ]" ] [
    \ unparse-test-2 "lambda" word-prop body>> first unparse
] unit-test

:: unparse-test-3 ( -- b ) [| a! | ] ;

[ "[| a! | ]" ] [
    \ unparse-test-3 "lambda" word-prop body>> first unparse
] unit-test

DEFER: xyzzy

[ ] [
    "IN: locals.tests USE: math GENERIC: xyzzy M: integer xyzzy ;"
    <string-reader> "lambda-generic-test" parse-stream drop
] unit-test

[ 10 ] [ 10 xyzzy ] unit-test

[ ] [
    "IN: locals.tests USE: math USE: locals GENERIC: xyzzy M:: integer xyzzy ( n -- ) 5 ;"
    <string-reader> "lambda-generic-test" parse-stream drop
] unit-test

[ 5 ] [ 10 xyzzy ] unit-test

:: let*-test-1 ( a -- b )
    [let* | b [ a 1+ ]
            c [ b 1+ ] |
        a b c 3array ] ;

[ { 1 2 3 } ] [ 1 let*-test-1 ] unit-test

:: let*-test-2 ( a -- b )
    [let* | b [ a 1+ ]
            c! [ b 1+ ] |
        a b c 3array ] ;

[ { 1 2 3 } ] [ 1 let*-test-2 ] unit-test

:: let*-test-3 ( a -- b )
    [let* | b [ a 1+ ]
            c! [ b 1+ ] |
        c 1+ c!  a b c 3array ] ;

[ { 1 2 4 } ] [ 1 let*-test-3 ] unit-test

:: let*-test-4 ( a b -- c d )
    [let | a [ b ]
           b [ a ] |
        [let* | a'  [ a  ]
                a'' [ a' ]
                b'  [ b  ]
                b'' [ b' ] |
            a'' b'' ] ] ;

[ "xxx" "yyy" ] [ "yyy" "xxx" let*-test-4 ] unit-test

GENERIC: next-method-test ( a -- b )

M: integer next-method-test 3 + ;

M:: fixnum next-method-test ( a -- b ) a call-next-method 1 + ;

[ 5 ] [ 1 next-method-test ] unit-test

: no-with-locals-test { 1 2 3 } [| x | x 3 + ] map ;

[ { 4 5 6 } ] [ no-with-locals-test ] unit-test

{ 3 0 } [| a b c | ] must-infer-as

[ ] [ 1 [let | a [ ] | ] ] unit-test

[ 3 ] [ 1 [let | a [ ] | 3 ] ] unit-test

[ ] [ 1 2 [let | a [ ] b [ ] | ] ] unit-test

:: a-word-with-locals ( a b -- ) ;

: new-definition "IN: locals.tests\nUSING: math ;\n: a-word-with-locals ( -- x ) 2 3 + ;\n" ;

[ ] [ new-definition eval ] unit-test

[ t ] [
    [ \ a-word-with-locals see ] with-string-writer
    new-definition =
] unit-test
