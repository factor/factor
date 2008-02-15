! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays prettyprint sequences kernel
vectors quotations words parser assocs combinators
continuations debugger io io.files vocabs tools.time
vocabs.loader source-files compiler.units inspector
inference effects ;
IN: tools.test

SYMBOL: failures

: <failure> ( error what -- triple )
    error-continuation get 3array ;

: failure ( error what -- )
    <failure> failures get push ;

SYMBOL: this-test

: (unit-test) ( what quot -- )
    swap dup . flush this-test set
    [ time ] curry failures get [
        [ this-test get failure ] recover
    ] [
        call
    ] if ;

: unit-test ( output input -- )
    [ 2array ] 2keep [
        { } swap with-datastack swap >array assert=
    ] 2curry (unit-test) ;

: short-effect ( effect -- pair )
    dup effect-in length swap effect-out length 2array ;

: must-infer-as ( effect quot -- )
    >r 1quotation r> [ infer short-effect ] curry unit-test ;

: must-infer ( word/quot -- )
    dup word? [ 1quotation ] when
    [ infer drop ] curry [ ] swap unit-test ;

: must-fail-with ( quot pred -- )
    >r [ f ] compose r>
    [ recover ] 2curry
    [ t ] swap unit-test ;

: must-fail ( quot -- )
    [ drop t ] must-fail-with ;

: ignore-errors ( quot -- )
    [ drop ] recover ; inline

: (run-test) ( vocab -- )
    dup vocab-source-loaded? [
        vocab-tests
        [
            "temporary" forget-vocab
            dup [ forget-source ] each
        ] with-compilation-unit
        dup [ run-file ] each
    ] when drop ;

: run-test ( vocab -- failures )
    V{ } clone [
        failures [
            [ (run-test) ] [ swap failure ] recover
        ] with-variable
    ] keep ;

: failure. ( triple -- )
    dup second .
    dup first print-error
    "Traceback" swap third write-object ;

: test-failures. ( assoc -- )
    [
        nl
        dup empty? [
            drop
            "==== ALL TESTS PASSED" print
        ] [
            "==== FAILING TESTS:" print
            [
                swap vocab-heading.
                [ failure. nl ] each
            ] assoc-each
        ] if
    ] [
        "==== NOTHING TO TEST" print
    ] if* ;

: run-tests ( prefix -- failures )
    child-vocabs dup empty? [ drop f ] [
        [ dup run-test ] { } map>assoc
        [ second empty? not ] subset
    ] if ;

: test ( prefix -- )
    run-tests test-failures. ;

: run-all-tests ( prefix -- failures )
    "" run-tests ;

: test-all ( -- )
    run-all-tests test-failures. ;
