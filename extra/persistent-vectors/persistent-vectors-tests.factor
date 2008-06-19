IN: persistent-vectors.tests
USING: tools.test persistent-vectors sequences kernel arrays
random namespaces vectors math math.order ;

\ new-nth must-infer
\ ppush must-infer
\ ppop must-infer

[ 0 ] [ pempty length ] unit-test

[ 1 ] [ 3 pempty ppush length ] unit-test

[ 3 ] [ 3 pempty ppush first ] unit-test

[ PV{ 3 1 3 3 7 } ] [
    pempty { 3 1 3 3 7 } [ swap ppush ] each
] unit-test

[ { 3 1 3 3 7 } ] [
    pempty { 3 1 3 3 7 } [ swap ppush ] each >array
] unit-test

{ 100 1060 2000 10000 100000 1000000 } [
    [ t ] swap [ dup >persistent-vector sequence= ] curry unit-test
] each

[ ] [ 10000 [ 16 random-bits ] PV{ } replicate-as "1" set ] unit-test
[ ] [ "1" get >vector "2" set ] unit-test

[ t ] [
    3000 [
        drop
        16 random-bits 10000 random
        [ "1" [ new-nth ] change ]
        [ "2" [ new-nth ] change ] 2bi
        "1" get "2" get sequence=
    ] all?
] unit-test

[ PV{ } ppop ] [ empty-error? ] must-fail-with

[ t ] [ PV{ 3 } ppop empty? ] unit-test

[ PV{ 3 7 } ] [ PV{ 3 7 6 } ppop ] unit-test

[ PV{ 3 7 6 5 } ] [ 5 PV{ 3 7 6 } ppush ] unit-test

[ ] [ PV{ } "1" set ] unit-test
[ ] [ V{ } clone "2" set ] unit-test

: push/pop-test ( vec -- vec' ) 3 swap ppush 3 swap ppush ppop ;

[ ] [ PV{ } 10000 [ push/pop-test ] times drop ] unit-test

[ t ] [
    100 [
        drop
        100 random [
            16 random-bits [ "1" [ ppush ] change ] [ "2" get push ] bi
        ] times
        100 random "1" get length min [
            "1" [ ppop ] change
            "2" get pop*
        ] times
        "1" get "2" get sequence=
    ] all?
] unit-test
