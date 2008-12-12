! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors namespaces arrays prettyprint sequences kernel
vectors quotations words parser assocs combinators continuations
debugger io io.styles io.files vocabs vocabs.loader source-files
compiler.units summary stack-checker effects tools.vocabs fry ;
IN: tools.test

SYMBOL: failures

: <failure> ( error what -- triple )
    error-continuation get 3array ;

: failure ( error what -- )
    "--> test failed!" print
    <failure> failures get push ;

SYMBOL: this-test

: (unit-test) ( what quot -- )
    swap dup . flush this-test set
    failures get [
        [ this-test get failure ] recover
    ] [
        call
    ] if ;

: unit-test ( output input -- )
    [ 2array ] 2keep '[
        _ { } _ with-datastack swap >array assert=
    ] (unit-test) ;

: short-effect ( effect -- pair )
    [ in>> length ] [ out>> length ] bi 2array ;

: must-infer-as ( effect quot -- )
    [ 1quotation ] dip '[ _ infer short-effect ] unit-test ;

: must-infer ( word/quot -- )
    dup word? [ 1quotation ] when
    '[ _ infer drop ] [ ] swap unit-test ;

: must-fail-with ( quot pred -- )
    [ '[ @ f ] ] dip '[ _ _ recover ] [ t ] swap unit-test ;

: must-fail ( quot -- )
    [ drop t ] must-fail-with ;

: (run-test) ( vocab -- )
    dup vocab source-loaded?>> [
        vocab-tests [ run-file ] each
    ] [ drop ] if ;

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
        [
            "==== ALL TESTS PASSED" print
        ] [
            "==== FAILING TESTS:" print
            [
                swap vocab-heading.
                [ failure. nl ] each
            ] assoc-each
        ] if-empty
    ] [
        "==== NOTHING TO TEST" print
    ] if* ;

: run-tests ( prefix -- failures )
    child-vocabs [ f ] [
        [ dup run-test ] { } map>assoc
        [ second empty? not ] filter
    ] if-empty ;

: test ( prefix -- )
    run-tests test-failures. ;

: run-all-tests ( -- failures )
    "" run-tests ;

: test-all ( -- )
    run-all-tests test-failures. ;
