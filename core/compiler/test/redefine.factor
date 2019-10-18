USING: compiler definitions generic assocs inference math
namespaces parser tools.test words kernel sequences arrays io
effects tools.test.inference ;
IN: temporary

parse-hook get [
    DEFER: foo \ foo reset-generic
    DEFER: bar \ bar reset-generic

    [   ] [ \ foo [ 1 2 ] define-compound ] unit-test
    { 0 2 } [ foo ] unit-test-effect
    [   ] [ \ foo compile ] unit-test
    [   ] [ \ bar [ foo foo ] define-compound ] unit-test
    [   ] [ \ bar compile ] unit-test
    [   ] [ \ foo [ 1 2 3 ] define-compound ] unit-test
    [ t ] [ \ bar changed-words get key? ] unit-test
    [   ] [ recompile ] unit-test
    { 0 3 } [ foo ] unit-test-effect
    [ f ] [ \ bar changed-words get key? ] unit-test
    [   ] [ \ bar [ 1 2 ] define-compound ] unit-test
    [ t ] [ \ bar changed-words get key? ] unit-test
    [   ] [ recompile ] unit-test
    { 0 2 } [ bar ] unit-test-effect
    [ f ] [ \ bar changed-words get key? ] unit-test
    [   ] [ \ foo [ 1 2 3 ] define-compound ] unit-test
    [ f ] [ \ bar changed-words get key? ] unit-test
    [   ] [ \ bar [ 1 2 3 ] define-compound ] unit-test
    [ t ] [ \ bar changed-words get key? ] unit-test
    [   ] [ \ bar forget ] unit-test
    [ f ] [ \ bar changed-words get key? ] unit-test

    : xy ;
    : yx xy ;

    \ yx compile
    
    \ xy [ 1 ] define-compound

    [ ] [ recompile ] unit-test

    [ 1 ] [ yx ] unit-test
] when
