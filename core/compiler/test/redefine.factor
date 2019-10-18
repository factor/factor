USING: compiler definitions generic assocs inference math
namespaces parser tools.test words kernel sequences arrays io
effects ;
IN: temporary

parse-hook get [
    DEFER: foo \ foo reset-generic
    DEFER: bar \ bar reset-generic

    : short-effect
        dup effect-in length swap effect-out length 2array ;

    [   ] [ \ foo [ 1 2 ] define-compound     ] unit-test
    [ { 0 2 } ] [ [ foo ] infer short-effect ] unit-test
    [   ] [ \ foo compile                     ] unit-test
    [   ] [ \ bar [ foo foo ] define-compound ] unit-test
    [   ] [ \ bar compile                     ] unit-test
    [   ] [ \ foo [ 1 2 3 ] define-compound   ] unit-test
    [ t ] [ \ bar changed-words get key?  ] unit-test
    [   ] [ recompile ] unit-test
    [ { 0 3 } ] [ [ foo ] infer short-effect ] unit-test
    [ f ] [ \ bar changed-words get key?  ] unit-test
    [   ] [ \ bar [ 1 2 ] define-compound     ] unit-test
    [ t ] [ \ bar changed-words get key?  ] unit-test
    [   ] [ recompile ] unit-test
    [ { 0 2 } ] [ [ bar ] infer short-effect ] unit-test
    [ f ] [ \ bar changed-words get key?  ] unit-test
    [   ] [ \ foo [ 1 2 3 ] define-compound   ] unit-test
    [ f ] [ \ bar changed-words get key?  ] unit-test
    [   ] [ \ bar [ 1 2 3 ] define-compound   ] unit-test
    [ t ] [ \ bar changed-words get key?  ] unit-test
    [   ] [ \ bar forget ] unit-test
    [ f ] [ \ bar changed-words get key?  ] unit-test

    : xy ;
    : yx xy ;

    \ yx compile
    
    \ xy [ 1 ] define-compound

    [ ] [ recompile ] unit-test

    [ 1 ] [ yx ] unit-test
] when
