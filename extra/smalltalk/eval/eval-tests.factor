IN: smalltalk.eval.tests
USING: smalltalk.eval tools.test io.streams.string ;

[ 3 ] [ "1+2" eval-smalltalk ] unit-test
[ "HAI" ] [ "(1<10) ifTrue:['HAI'] ifFalse:['BAI']" eval-smalltalk ] unit-test
[ 7 ] [ "1+2+3;+4" eval-smalltalk ] unit-test
[ 6 "5\n6\n" ] [ [ "[:x|x print] value: 5; value: 6" eval-smalltalk ] with-string-writer ] unit-test