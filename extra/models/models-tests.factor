IN: temporary
USING: arrays generic kernel math models namespaces sequences
tools.test assocs ;

TUPLE: model-tester hit? ;

: <model-tester> model-tester construct-empty ;

M: model-tester model-changed t swap set-model-tester-hit? ;

[ T{ model-tester f t } ]
[
    T{ model-tester f f } 3 <model> 2dup add-connection
    5 swap set-model
] unit-test

3 <model> "model-a" set
4 <model> "model-b" set
"model-a" get "model-b" get 2array <compose> "model-c" set

"model-c" get activate-model
[ { 3 4 } ] [ "model-c" get model-value  ] unit-test
"model-c" get deactivate-model

T{ model-tester f f } "tester" set

[ T{ model-tester f t } { 6 4 } ]
[
    "tester" get "model-c" get add-connection
    6 "model-a" get set-model
    "tester" get
    "model-c" get model-value
] unit-test

f <history> "history" set

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

! Test multiple filters
3 <model> "x" set
"x" get [ 2 * ] <filter> dup "z" set
[ 1+ ] <filter> "y" set
[ ] [ "y" get activate-model ] unit-test
[ t ] [ "z" get "x" get model-connections memq? ] unit-test
[ 7 ] [ "y" get model-value ] unit-test
[ ] [ 4 "x" get set-model ] unit-test
[ 9 ] [ "y" get model-value ] unit-test
[ ] [ "y" get deactivate-model ] unit-test
[ f ] [ "z" get "x" get model-connections memq? ] unit-test

3 <model> "x" set
"x" get [ sq ] <filter> "y" set

4 "x" get set-model

"y" get activate-model
[ 16 ] [ "y" get model-value ] unit-test
"y" get deactivate-model

! Test compose
[ ] [
    1 <model> "a" set
    2 <model> "b" set
    "a" get "b" get 2array <compose> "c" set
] unit-test

[ ] [ "c" get activate-model ] unit-test

[ { 1 2 } ] [ "c" get model-value ] unit-test

[ ] [ 3 "b" get set-model ] unit-test

[ { 1 3 } ] [ "c" get model-value ] unit-test

[ ] [ { 4 5 } "c" get set-model ] unit-test

[ { 4 5 } ] [ "c" get model-value ] unit-test

[ ] [ "c" get deactivate-model ] unit-test

! Test mapping
[ ] [
    [
        1 <model> "one" set
        2 <model> "two" set
    ] H{ } make-assoc
    <mapping> "m" set
] unit-test

[ ] [ "m" get activate-model ] unit-test

[ H{ { "one" 1 } { "two" 2 } } ] [
    "m" get model-value
] unit-test

[ ] [
    H{ { "one" 3 } { "two" 4 } } 
    "m" get set-model
] unit-test

[ H{ { "one" 3 } { "two" 4 } } ] [
    "m" get model-value
] unit-test

[ H{ { "one" 5 } { "two" 4 } } ] [
    5 "one" "m" get mapping-assoc at set-model
    "m" get model-value
] unit-test

[ ] [ "m" get deactivate-model ] unit-test
