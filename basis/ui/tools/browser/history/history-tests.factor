USING: namespaces ui.tools.browser.history sequences tools.test ;
IN: ui.tools.browser.history.tests

f <history> "history" set

"history" get add-history

[ t ] [ "history" get back>> empty? ] unit-test
[ t ] [ "history" get forward>> empty? ] unit-test

"history" get add-history
"history" get 3 >>value drop

[ t ] [ "history" get back>> empty? ] unit-test
[ t ] [ "history" get forward>> empty? ] unit-test

"history" get add-history
"history" get 4 >>value drop

[ f ] [ "history" get back>> empty? ] unit-test
[ t ] [ "history" get forward>> empty? ] unit-test

"history" get go-back

[ 3 ] [ "history" get value>> ] unit-test

[ t ] [ "history" get back>> empty? ] unit-test
[ f ] [ "history" get forward>> empty? ] unit-test

"history" get go-forward

[ 4 ] [ "history" get value>> ] unit-test

[ f ] [ "history" get back>> empty? ] unit-test
[ t ] [ "history" get forward>> empty? ] unit-test

