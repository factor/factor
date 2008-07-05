USING: alien arrays definitions generic assocs hashtables io
kernel math namespaces parser prettyprint sequences strings
tools.test vectors words quotations classes
classes.private classes.union classes.mixin classes.predicate
classes.algebra vectors definitions source-files
compiler.units kernel.private sorting vocabs ;
IN: classes.tests

[ t ] [ 3 object instance? ] unit-test
[ t ] [ 3 fixnum instance? ] unit-test
[ f ] [ 3 float instance? ] unit-test
[ t ] [ 3 number instance? ] unit-test
[ f ] [ 3 null instance? ] unit-test
[ t ] [ "hi" \ hi-tag instance? ] unit-test

! Regression
GENERIC: method-forget-test ( obj -- obj )
TUPLE: method-forget-class ;
M: method-forget-class method-forget-test ;

[ f ] [ \ method-forget-test "methods" word-prop assoc-empty? ] unit-test
[ ] [ [ \ method-forget-class forget ] with-compilation-unit ] unit-test
[ t ] [ \ method-forget-test "methods" word-prop assoc-empty? ] unit-test

[ t ] [
    all-words [ class? ] filter
    implementors-map get keys
    [ natural-sort ] bi@ =
] unit-test
