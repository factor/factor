IN: smalltalk.eval.tests
USING: smalltalk.eval tools.test ;

[ 3 ] [ "1+2" eval-smalltalk ] unit-test
[ "HAI" ] [ "(1<10) ifTrue:['HAI'] ifFalse:['BAI']" eval-smalltalk ] unit-test