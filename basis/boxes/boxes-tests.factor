USING: accessors boxes namespaces tools.test kernel ;

{ } [ <box> "b" set ] unit-test

{ } [ 3 "b" get >box ] unit-test

{ t } [ "b" get occupied>> ] unit-test

[ 4 "b" >box ] must-fail

{ 3 } [ "b" get box> ] unit-test

{ f } [ "b" get occupied>> ] unit-test

[ "b" get box> ] must-fail

{ f f } [ "b" get ?box ] unit-test

{ } [ 12 "b" get >box ] unit-test

{ 12 t } [ "b" get ?box ] unit-test

{ f } [ "b" get occupied>> ] unit-test

[ <box> check-box ] [ box-empty? ] must-fail-with

{ 5 } [ <box> 5 over >box [ ] if-box? ] unit-test

{ } [ <box> [ "impossible" throw ] if-box? ] unit-test
