IN: compiler.tests.redefine22
USING: kernel sequences compiler.units vocabs tools.test definitions ;

TUPLE: ttt ;
INSTANCE: ttt sequence
M: ttt new-sequence 2drop ttt new ;

: www-1 ( a -- b ) T{ ttt } new-sequence ;

! This used to break with a compiler error in the above word
{ } [ [ \ ttt forget ] with-compilation-unit ] unit-test
