USING: arrays generic kernel math models models.product
namespaces sequences assocs accessors tools.test ;
IN: models.tests

TUPLE: model-tester hit? ;

: <model-tester> ( -- model-tester ) model-tester new ;

M: model-tester model-changed nip t >>hit? drop ;

[ T{ model-tester f t } ]
[
    T{ model-tester f f } 3 <model> 2dup add-connection
    5 swap set-model
] unit-test

3 <model> "model-a" set
4 <model> "model-b" set
"model-a" get "model-b" get 2array <product> "model-c" set

"model-c" get activate-model
[ { 3 4 } ] [ "model-c" get value>>  ] unit-test
"model-c" get deactivate-model

T{ model-tester f f } "tester" set

[ T{ model-tester f t } { 6 4 } ]
[
    "tester" get "model-c" get add-connection
    6 "model-a" get set-model
    "tester" get
    "model-c" get value>>
] unit-test
