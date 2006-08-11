USING: compiler definitions generic hashtables inference math
namespaces parser test words ;
IN: temporary

DEFER: foo
DEFER: bar

[   ] [ \ foo [ 1 2 ] define-compound     ] unit-test
[ { 0 2 } ] [ [ foo ] infer ] unit-test
[   ] [ \ foo compile                     ] unit-test
[   ] [ \ bar [ foo foo ] define-compound ] unit-test
[   ] [ \ bar compile                     ] unit-test
[   ] [ \ foo [ 1 2 3 ] define-compound   ] unit-test
[ t ] [ \ bar changed-words get hash-member?  ] unit-test
[   ] [ recompile ] unit-test
[ { 0 3 } ] [ [ foo ] infer ] unit-test
[ f ] [ \ bar changed-words get hash-member?  ] unit-test
[   ] [ \ bar [ 1 2 ] define-compound     ] unit-test
[ t ] [ \ bar changed-words get hash-member?  ] unit-test
[   ] [ recompile ] unit-test
[ { 0 2 } ] [ [ bar ] infer ] unit-test
[ f ] [ \ bar changed-words get hash-member?  ] unit-test
[   ] [ \ foo [ 1 2 3 ] define-compound   ] unit-test
[ f ] [ \ bar changed-words get hash-member?  ] unit-test
[   ] [ \ bar [ 1 2 3 ] define-compound   ] unit-test
[ t ] [ \ bar changed-words get hash-member?  ] unit-test
[   ] [ \ bar forget ] unit-test
[ f ] [ \ bar changed-words get hash-member?  ] unit-test
