IN: temporary
USING: boxes namespaces tools.test ;

[ ] [ <box> "b" set ] unit-test

[ ] [ 3 "b" get >box ] unit-test

[ t ] [ "b" get box-full? ] unit-test

[ 4 "b" >box ] must-fail

[ 3 ] [ "b" get box> ] unit-test

[ f ] [ "b" get box-full? ] unit-test

[ "b" get box> ] must-fail

[ f f ] [ "b" get ?box ] unit-test

[ ] [ 12 "b" get >box ] unit-test

[ 12 t ] [ "b" get ?box ] unit-test

[ f ] [ "b" get box-full? ] unit-test
