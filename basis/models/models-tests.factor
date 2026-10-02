USING: accessors arrays assocs continuations generic kernel locals math models models.arrow
models.product namespaces sequences tools.test ;
IN: models.tests

TUPLE: model-tester hit? ;

: <model-tester> ( -- model-tester ) model-tester new ;

M: model-tester model-changed nip t >>hit? drop ;

{ T{ model-tester f t } }
[
    T{ model-tester f f } clone 3 <model> 2dup add-connection
    5 swap set-model
] unit-test

3 <model> "model-a" set
4 <model> "model-b" set
"model-a" get "model-b" get 2array <product> "model-c" set

"model-c" get activate-model
{ { 3 4 } } [ "model-c" get value>>  ] unit-test
"model-c" get deactivate-model

T{ model-tester f f } "tester" set

{ T{ model-tester f t } { 6 4 } }
[
    "tester" get "model-c" get add-connection
    6 "model-a" get set-model
    "tester" get
    "model-c" get value>>
] unit-test

{ T{ model-tester f t } V{ 5 } }
[
    T{ model-tester f f } clone V{ } clone <model> 2dup add-connection
    5 swap [ push-model ] [ value>> ] bi
] unit-test

{ T{ model-tester f t } 5 V{ }  }
[
    T{ model-tester f f } clone V{ 5 } clone <model> 2dup add-connection
    [ pop-model ] [ value>> ] bi
] unit-test

{ f } [ 46 <model> [ 1 + ] <arrow> value>> ] unit-test
{ 47 } [ 46 <model> [ 1 + ] <arrow> compute-model ] unit-test
{ 0 } [ 46 <model> [ 1 + ] <arrow> [ compute-model drop ] keep ref>> ] unit-test

TUPLE: touch-test-model < model updates ;
M: touch-test-model update-model
    [ 1 + ] change-updates drop ;

TUPLE: touch-observer hits ;
M: touch-observer model-changed
    [ 1 + ] change-hits drop touch-model ;

! In-place mutation keeps object identity and runs both hooks exactly once.
{ t 1 1 f } [
    [let
        V{ 1 } clone :> value
        value touch-test-model new-model 0 >>updates :> model
        0 touch-observer boa model add-connection
        2 value push
        model touch-model
        model value>> value eq?
        model updates>>
        model connections>> first hits>>
        model locked?>>
    ]
] unit-test

! An already locked model neither updates nor notifies.
{ 0 } [
    1 touch-test-model new-model 0 >>updates t >>locked?
    [ touch-model ] keep updates>>
] unit-test

TUPLE: failing-touch-model < model ;
M: failing-touch-model update-model drop "touch failed" throw ;

{ f } [
    1 failing-touch-model new-model
    [ [ touch-model ] [ 2drop ] recover ] keep locked?>>
] unit-test
