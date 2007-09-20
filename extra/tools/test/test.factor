! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces arrays prettyprint sequences kernel
vectors quotations words parser assocs combinators
continuations debugger io io.files vocabs tools.time
vocabs.loader source-files ;
IN: tools.test

SYMBOL: failures

: <failure> ( error what -- triple )
    error-continuation get 3array ;

: failure ( error what -- ) <failure> failures get push ;

SYMBOL: this-test

: (unit-test) ( what quot -- )
    swap dup . flush this-test set
    [ time ] curry failures get [
        [
            this-test get <failure> failures get push
        ] recover
    ] [
        call
    ] if ;

: unit-test ( output input -- )
    [ 2array ] 2keep [
        { } swap with-datastack swap >array assert=
    ] 2curry (unit-test) ;

TUPLE: expected-error ;

: unit-test-fails ( quot -- )
    [ f ] append [ [ drop t ] recover ] curry
    [ t ] swap unit-test ;

: run-test ( path -- failures )
    "temporary" forget-vocab
    [
        V{ } clone [
            failures [
                [ run-file ] [ swap failure ] recover
            ] with-variable
        ] keep
    ] keep forget-source ;

: failure. ( triple -- )
    dup second .
    dup first print-error
    "Traceback" swap third write-object ;

: failures. ( path failures -- )
    "Failing tests in " write swap <pathname> .
    [ nl failure. nl ] each ;

: run-tests ( seq -- )
    [ dup run-test ] { } map>assoc
    [ second empty? not ] subset
    dup empty? [ drop ] [
        nl
        "==== FAILING TESTS:" print
        [ nl failures. ] assoc-each
    ] if ;

: run-vocab-tests ( vocabs -- )
    [ vocab-tests-path ] map
    [ dup [ ?resource-path exists? ] when ] subset
    run-tests ;

: test ( prefix -- )
    child-vocabs
    [ vocab-source-loaded? ] subset
    run-vocab-tests ;

: test-all ( -- ) "" test ;

: test-changes ( -- ) "" (refresh) run-vocab-tests ;
