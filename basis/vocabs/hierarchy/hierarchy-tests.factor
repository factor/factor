USING: continuations kernel namespaces sequences tools.test
vocabs.hierarchy vocabs.hierarchy.private ;
IN: vocabs.hierarchy.tests

: math? ( seq -- ? ) "math" swap member? ;

[ t ] [ "resource:core" vocabs-from math? ] unit-test
[ t ] [ "resource:core/" vocabs-from math? ] unit-test
[ t ] [ "resource:core\\" vocabs-from math? ] unit-test
[ t ] [ "resource:core." vocabs-from math? ] unit-test
[ t ] [ "resource:core/math" vocabs-from math? ] unit-test
[ t ] [ "resource:core\\math" vocabs-from math? ] unit-test

[ t ] [ all-vocab-names math? ] unit-test

[ t ] [ "math" child-vocab-names "math.floats" swap member? ] unit-test
[ t ] [ "resource:core" child-vocab-names math? ] unit-test

[ t ] [ "resource:core" loaded-vocabs-from math? ] unit-test

[ ] [ "resource:core" unloaded-vocabs-from drop ] unit-test

[ f ] [ all-tags empty? ] unit-test

