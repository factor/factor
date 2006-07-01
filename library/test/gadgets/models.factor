IN: temporary
USING: arrays kernel models namespaces sequences test ;

TUPLE: model-tester hit? ;

C: model-tester ;

M: model-tester model-changed t swap set-model-tester-hit? ;

[ T{ model-tester f f } ]
[
    T{ model-tester f f } 3 <model> 2dup add-connection
    3 swap set-model
] unit-test

[ T{ model-tester f t } ]
[
    T{ model-tester f f } 3 <model> 2dup add-connection
    5 swap set-model
] unit-test

3 <model> "model-a" set
4 <model> "model-b" set
"model-a" get "model-b" get 2array <compose> "model-c" set

[ { 3 4 } ] [ "model-c" get model-value  ] unit-test

T{ model-tester f f } "tester" set

[ T{ model-tester f t } { 6 4 } ]
[
    "tester" get "model-c" get add-connection
    6 "model-a" get set-model
    "tester" get
    "model-c" get model-value
] unit-test

<history> "history" set

"history" get add-history

[ t ] [ "history" get history-back empty? ] unit-test
[ t ] [ "history" get history-forward empty? ] unit-test

"history" get add-history
3 "history" get set-model

[ t ] [ "history" get history-back empty? ] unit-test
[ t ] [ "history" get history-forward empty? ] unit-test

"history" get add-history
4 "history" get set-model

[ f ] [ "history" get history-back empty? ] unit-test
[ t ] [ "history" get history-forward empty? ] unit-test

"history" get go-back

[ 3 ] [ "history" get model-value ] unit-test

[ t ] [ "history" get history-back empty? ] unit-test
[ f ] [ "history" get history-forward empty? ] unit-test

"history" get go-forward

[ 4 ] [ "history" get model-value ] unit-test

[ f ] [ "history" get history-back empty? ] unit-test
[ t ] [ "history" get history-forward empty? ] unit-test
