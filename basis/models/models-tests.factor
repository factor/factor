USING: accessors arrays assocs generic kernel math models models.arrow
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
