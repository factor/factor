! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: errors namespaces arrays prettyprint io sequences kernel
vectors quotations words parser tools assocs ;
IN: test

SYMBOL: failures

: <failure> ( error what -- triple )
    error-continuation get 3array ;

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
        V{ } swap with-datastack swap >vector assert=
    ] curry curry (unit-test) ;

TUPLE: expected-error ;

: unit-test-fails ( quot -- )
    [ f ] append [ [ drop t ] recover ] curry
    [ t ] swap unit-test ;

: run-test ( path -- failures )
    [
        "temporary" forget-vocab
        V{ } clone failures set
        [ run-file { } ] [ swap <failure> 1array ] recover
        failures get append
    ] with-scope ;

: failure. ( triple -- )
    dup second .
    dup first error.
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
