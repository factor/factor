! Copyright (C) 2003, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays prettyprint sequences kernel
vectors quotations words parser assocs combinators
continuations debugger io io.files vocabs tools.time
vocabs.loader source-files compiler.units inspector ;
IN: tools.test

SYMBOL: failures

: <failure> ( error what -- triple )
    error-continuation get 3array ;

: failure ( error what -- ) <failure> failures get push ;

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

TUPLE: expected-error ;

M: expected-error summary
    drop
    "The unit test expected the quotation to throw an error" ;

: must-fail-with ( quot test -- )
    >r [ expected-error construct-empty throw ] compose r>
    [ recover ] 2curry
    [ t ] swap unit-test ;

: must-fail ( quot -- )
    [ drop t ] must-fail-with ;

: ignore-errors ( quot -- )
    [ drop ] recover ; inline

: run-test ( path -- failures )
    [ "temporary" forget-vocab ] with-compilation-unit
    [
        V{ } clone [
            failures [
                [ run-file ] [ swap failure ] recover
            ] with-variable
        ] keep
    ] keep
    [ forget-source ] with-compilation-unit ;

: failure. ( triple -- )
    dup second .
    dup first print-error
    "Traceback" swap third write-object ;

: failures. ( assoc -- )
    dup [
        nl
        dup empty? [
            drop
            "==== ALL TESTS PASSED" print
        ] [
            "==== FAILING TESTS:" print
            [
                nl
                "Failing tests in " write swap <pathname> .
                [ nl failure. nl ] each
            ] assoc-each
        ] if
    ] [
        drop "==== NOTHING TO TEST" print
    ] if ;

: run-vocab-tests ( vocabs -- failures )
    dup empty? [ f ] [
        [ dup run-test ] { } map>assoc
        [ second empty? not ] subset
    ] if ;

: run-tests ( prefix -- failures )
    child-vocabs
    [ vocab-source-loaded? ] subset
    [ vocab-tests-path ] map
    [ dup [ ?resource-path exists? ] when ] subset
    run-vocab-tests ;

: test ( prefix -- )
    run-tests failures. ;

: run-all-tests ( prefix -- failures )
    "" run-tests ;

: test-all ( -- )
    run-all-tests failures. ;
