USING: boxes kernel namespaces refs tools.test ;
IN: refs.tests

! assoc-refs
[ 3 ] [
    H{ { "a" 3 } } "a" <value-ref> get-ref
] unit-test

[ 4 ] [
    4 H{ { "a" 3 } } clone "a" <value-ref>
    [ set-ref ] keep
    get-ref
] unit-test

[ "a" ] [
    H{ { "a" 3 } } "a" <key-ref> get-ref
] unit-test

[ H{ { "b" 3 } } ] [
    "b" H{ { "a" 3 } } clone [
        "a" <key-ref>
        set-ref
    ] keep
] unit-test

SYMBOLS: lion giraffe elephant rabbit ;

! obj-refs
[ rabbit ] [ rabbit <obj-ref> get-ref ] unit-test
[ rabbit ] [ f <obj-ref> rabbit set-ref* get-ref ] unit-test
[ rabbit ] [ rabbit <obj-ref> take ] unit-test
[ rabbit f ] [ rabbit <obj-ref> [ take ] keep get-ref ] unit-test
[ lion ] [ rabbit <obj-ref> dup [ drop lion ] change-ref get-ref ] unit-test

! var-refs 
[ giraffe ] [ [ giraffe rabbit set rabbit <var-ref> get-ref ] with-scope ] unit-test

[ rabbit ]
[
    [
        lion rabbit set [
            rabbit rabbit set rabbit <var-ref> get-ref
        ] with-scope
    ] with-scope
] unit-test

[ rabbit ] [
    rabbit <var-ref>
    [
        lion rabbit set [
            rabbit rabbit set get-ref
        ] with-scope
    ] with-scope
] unit-test

[ elephant ] [
    rabbit <var-ref>
    [
        elephant rabbit set [
            rabbit rabbit set
        ] with-scope
        get-ref
    ] with-scope
] unit-test

[ rabbit ] [
    rabbit <var-ref>
    [
        elephant set-ref* [
            rabbit set-ref* get-ref
        ] with-scope
    ] with-scope
] unit-test

[ elephant ] [
    rabbit <var-ref>
    [
        elephant set-ref* [
            rabbit set-ref*
        ] with-scope
        get-ref
    ] with-scope
] unit-test

! Top Hats
[ lion ] [ lion rabbit set-global rabbit <global-var-ref> get-ref ] unit-test
[ giraffe ] [ rabbit <global-var-ref> giraffe set-ref* get-ref ] unit-test

! Tuple refs
TUPLE: foo bar ;
C: <foo> foo

: test-tuple ( -- tuple )
    rabbit <foo> ;

: test-slot-ref ( -- slot-ref )
    test-tuple 2 <slot-ref> ; ! hack!

[ rabbit ] [ test-slot-ref get-ref ] unit-test
[ lion ] [ test-slot-ref lion set-ref* get-ref ] unit-test

! Boxes as refs
[ rabbit ] [ <box> rabbit set-ref* get-ref ] unit-test
[ <box> rabbit set-ref* lion set-ref* ] must-fail
[ <box> get-ref ] must-fail
