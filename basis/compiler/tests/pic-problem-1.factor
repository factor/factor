IN: compiler.tests.pic-problem-1
USING: kernel sequences prettyprint memory tools.test ;

TUPLE: x ;

M: x length drop 0 ;

INSTANCE: x sequence

<< gc >>

CONSTANT: blah T{ x }

[ T{ x } ] [ blah ] unit-test