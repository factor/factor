IN: smalltalk.eval.tests
USING: smalltalk.eval tools.test io.streams.string kernel ;

[ 3 ] [ "1+2" eval-smalltalk ] unit-test
[ "HAI" ] [ "(1<10) ifTrue:['HAI'] ifFalse:['BAI']" eval-smalltalk ] unit-test
[ 7 ] [ "1+2+3;+4" eval-smalltalk ] unit-test
[ 6 "5\n6\n" ] [ [ "[:x|x print] value: 5; value: 6" eval-smalltalk ] with-string-writer ] unit-test
[ 5 ] [ "|x| x:=5. x" eval-smalltalk ] unit-test
[ 11 ] [ "[:i| |x| x:=5. i+x] value: 6" eval-smalltalk ] unit-test
[ t ] [ "class Blah [method foo [5]]. Blah new foo" eval-smalltalk tuple? ] unit-test
[ 196418 ] [ "vocab:smalltalk/eval/fib.st" eval-smalltalk-file ] unit-test