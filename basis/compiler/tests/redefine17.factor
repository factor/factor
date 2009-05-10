IN: compiler.tests.redefine17
USING: tools.test classes.mixin compiler.units arrays kernel.private
strings sequences vocabs definitions kernel ;

<< "compiler.tests.redefine17" words forget-all >>

GENERIC: bong ( a -- b )

M: array bong ;

M: string bong length ;

MIXIN: mixin

INSTANCE: array mixin

: blah ( a -- b ) { mixin } declare bong ;

[ { } ] [ { } blah ] unit-test

[ ] [ [ \ array \ mixin remove-mixin-instance ] with-compilation-unit ] unit-test

[ ] [ [ \ string \ mixin add-mixin-instance ] with-compilation-unit ] unit-test

[ 0 ] [ "" blah ] unit-test

MIXIN: mixin1

INSTANCE: string mixin1

MIXIN: mixin2

GENERIC: billy ( a -- b )

M: mixin2 billy ;

M: array billy drop "BILLY" ;

INSTANCE: string mixin2

: bully ( a -- b ) { mixin1 } declare billy ;

[ "" ] [ "" bully ] unit-test

[ ] [ [ \ string \ mixin1 remove-mixin-instance ] with-compilation-unit ] unit-test

[ ] [ [ \ array \ mixin1 add-mixin-instance ] with-compilation-unit ] unit-test

[ "BILLY" ] [ { } bully ] unit-test
