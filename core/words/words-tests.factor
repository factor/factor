USING: arrays generic assocs kernel math namespaces
sequences tools.test words definitions parser quotations
vocabs continuations classes.tuple compiler.units
io.streams.string accessors eval words.symbol grouping ;
IN: words.tests

[ 4 ] [
    [
        "poo" "words.tests" create [ 2 2 + ] ( -- n ) define-declared
    ] with-compilation-unit
    "poo" "words.tests" lookup-word execute
] unit-test

[ t ] [ t vocabs [ words [ word? and ] each ] each ] unit-test

DEFER: plist-test

[ t ] [
    \ plist-test t "sample-property" set-word-prop
    \ plist-test "sample-property" word-prop
] unit-test

[ f ] [
    \ plist-test f "sample-property" set-word-prop
    \ plist-test "sample-property" word-prop
] unit-test

[ ] [ [ "create-test" "scratchpad" create { 1 2 } "testing" set-word-prop ] with-compilation-unit ] unit-test

[ { 1 2 } ] [
    "create-test" "scratchpad" lookup-word "testing" word-prop
] unit-test

[
    [ t ] [ \ array? "array?" "arrays" lookup-word = ] unit-test

    [ ] [ [ "test-scope" "scratchpad" create drop ] with-compilation-unit ] unit-test
] with-scope

[ "test-scope" ] [
    "test-scope" "scratchpad" lookup-word name>>
] unit-test

[ t ] [ vocabs array? ] unit-test
[ t ] [ vocabs [ words [ word? ] all? ] all? ] unit-test

[ f ] [ gensym gensym = ] unit-test

SYMBOL: a-symbol
[ t ] [ \ a-symbol symbol? ] unit-test

! See if redefining a generic as a colon def clears some
! word props.
GENERIC: testing ( a -- b )
"IN: words.tests : testing ( -- ) ;" eval( -- )

[ f ] [ \ testing generic? ] unit-test

: forgotten ( -- ) ;
: another-forgotten ( -- ) ;

FORGET: forgotten

FORGET: another-forgotten
: another-forgotten ( -- ) ;

! Make sure that undefined words throw proper errors
DEFER: deferred
[ deferred ] [ T{ undefined f deferred } = ] must-fail-with

[ "IN: words.tests DEFER: not-compiled << not-compiled >>" eval( -- ) ]
[ error>> [ undefined? ] [ word>> name>> "not-compiled" = ] bi and ] must-fail-with

[ ] [ "IN: words.tests FORGET: not-compiled" eval( -- ) ] unit-test

[ ] [ [ "no-loc" "words.tests" create drop ] with-compilation-unit ] unit-test
[ f ] [ "no-loc" "words.tests" lookup-word where ] unit-test

[ ] [ "IN: words.tests : no-loc-2 ( -- ) ;" eval( -- ) ] unit-test
[ f ] [ "no-loc-2" "words.tests" lookup-word where ] unit-test

[ ] [ "IN: words.tests : test-last ( -- ) ;" eval( -- ) ] unit-test
[ "test-last" ] [ last-word name>> ] unit-test

"undef-test" "words.tests" lookup-word [
    [ forget ] with-compilation-unit
] when*

[ "IN: words.tests : undef-test ( -- ) ; << undef-test >>" eval( -- ) ]
[ error>> undefined? ] must-fail-with

[ ] [
    "IN: words.tests GENERIC: symbol-generic ( -- )" eval( -- )
] unit-test

[ ] [
    "IN: words.tests SYMBOL: symbol-generic" eval( -- )
] unit-test

[ t ] [ "symbol-generic" "words.tests" lookup-word symbol? ] unit-test
[ f ] [ "symbol-generic" "words.tests" lookup-word generic? ] unit-test

[ ] [
    "IN: words.tests GENERIC: symbol-generic ( a -- b )" <string-reader>
    "symbol-generic-test" parse-stream drop
] unit-test

[ ] [
    "IN: words.tests TUPLE: symbol-generic ;" <string-reader>
    "symbol-generic-test" parse-stream drop
] unit-test

[ t ] [ "symbol-generic" "words.tests" lookup-word symbol? ] unit-test
[ f ] [ "symbol-generic" "words.tests" lookup-word generic? ] unit-test

! Regressions
[ ] [ "IN: words.tests : decl-forget-test ( -- ) ; foldable" eval( -- ) ] unit-test
[ t ] [ "decl-forget-test" "words.tests" lookup-word "foldable" word-prop ] unit-test
[ ] [ "IN: words.tests : decl-forget-test ( -- ) ;" eval( -- ) ] unit-test
[ f ] [ "decl-forget-test" "words.tests" lookup-word "foldable" word-prop ] unit-test

[ ] [ "IN: words.tests : decl-forget-test ( -- ) ; flushable" eval( -- ) ] unit-test
[ t ] [ "decl-forget-test" "words.tests" lookup-word "flushable" word-prop ] unit-test
[ ] [ "IN: words.tests : decl-forget-test ( -- ) ;" eval( -- ) ] unit-test
[ f ] [ "decl-forget-test" "words.tests" lookup-word "flushable" word-prop ] unit-test

[ { } ]
[
    all-words [
        [ "effect-dependencies" word-prop ]
        [ "definition-dependencies" word-prop ]
        [ "conditional-dependencies" word-prop ] tri
        3append [ "forgotten" word-prop ] filter
    ] map harvest
] unit-test

[ "hi" word-code ] must-fail
