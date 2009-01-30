USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.compose accessors locals ;
IN: models.compose.tests

! Test compose
[ ] [
    1 <model> "a" set
    2 <model> "b" set
    "a" get "b" get 2array <compose> "c" set
] unit-test

[ ] [ "c" get activate-model ] unit-test

[ { 1 2 } ] [ "c" get value>> ] unit-test

[ ] [ 3 "b" get set-model ] unit-test

[ { 1 3 } ] [ "c" get value>> ] unit-test

[ ] [ { 4 5 } "c" get set-model ] unit-test

[ { 4 5 } ] [ "c" get value>> ] unit-test

[ ] [ "c" get deactivate-model ] unit-test

TUPLE: an-observer { i integer } ;

M: an-observer model-changed nip [ 1+ ] change-i drop ;

[ 1 0 ] [
    [let* | m1 [ 1 <model> ]
            m2 [ 2 <model> ]
            c [ { m1 m2 } <compose> ]
            o1 [ an-observer new ]
            o2 [ an-observer new ] |
        
        o1 m1 add-connection
        o2 m2 add-connection

        c activate-model
    
        "OH HAI" m1 set-model
        o1 i>>
        o2 i>>
    ]
] unit-test