IN: models.history.tests
USING: arrays generic kernel math models namespaces sequences assocs
tools.test models.history ;

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

