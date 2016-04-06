! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators command-line
compiler.units continuations debugger effects fry
generalizations io io.files.temp io.files.unique kernel lexer
locals macros namespaces parser prettyprint quotations sequences
sequences.generalizations source-files source-files.errors
source-files.errors.debugger splitting stack-checker summary
tools.errors unicode vocabs vocabs.files vocabs.metadata
vocabs.parser words ;
FROM: vocabs.hierarchy => load ;
IN: tools.test

TUPLE: test-failure < source-file-error continuation ;

SYMBOL: +test-failure+

M: test-failure error-type drop +test-failure+ ;

SYMBOL: test-failures

test-failures [ V{ } clone ] initialize

T{ error-type-holder
   { type +test-failure+ }
   { word ":test-failures" }
   { plural "unit test failures" }
   { icon "vocab:ui/tools/error-list/icons/unit-test-error.tiff" }
   { quot [ test-failures get ] }
} define-error-type

SYMBOL: verbose-tests?
t verbose-tests? set-global

SYMBOL: restartable-tests?
t restartable-tests? set-global

: <test-failure> ( error experiment path line# -- test-failure )
    test-failure new
        swap >>line#
        swap >>path
        swap >>asset
        swap >>error
        error-continuation get >>continuation ;

<PRIVATE

: failure ( error experiment path line# -- )
    "--> test failed!" print
    <test-failure> test-failures get push
    notify-error-observers ;

SYMBOL: current-test-file

: file-failure ( error -- )
    [ f current-test-file get ] keep error-line failure ;

:: (unit-test) ( output input -- error ? )
    [ { } input with-datastack output assert-sequence= f f ] [ t ] recover ;

: short-effect ( effect -- pair )
    [ in>> length ] [ out>> length ] bi 2array ;

:: (must-infer-as) ( effect quot -- error ? )
    [ quot infer short-effect effect assert= f f ] [ t ] recover ;

:: (must-infer) ( quot -- error ? )
    [ quot infer drop f f ] [ t ] recover ;

TUPLE: did-not-fail ;
CONSTANT: did-not-fail-literal T{ did-not-fail }

M: did-not-fail summary drop "Did not fail" ;

:: (must-fail-with) ( quot pred -- error ? )
    [ { } quot with-datastack drop did-not-fail-literal t ]
    [ dup pred call( error -- ? ) [ drop f f ] [ t ] if ] recover ;

:: (must-fail) ( quot -- error ? )
    [ { } quot with-datastack drop did-not-fail-literal t ] [ drop f f ] recover ;

: experiment-title ( word -- string )
    "(" ?head drop ")" ?tail drop
    H{ { CHAR: - CHAR: \s } } substitute >title ;

MACRO: <experiment> ( word -- quot )
    [ stack-effect in>> length dup ]
    [ name>> experiment-title ] bi
    '[ _ ndup _ narray _ prefix ] ;

: experiment. ( seq -- )
    [ first write ": " write ]
    [ rest verbose-tests? get [ . ] [ short. ] if flush ] bi ;

:: experiment ( word: ( -- error ? ) line# -- )
    word <experiment> :> e
    e experiment.
    word execute [
        current-test-file get [
            e current-test-file get line# failure
        ] [ rethrow ] if
    ] [ drop ] if ; inline

: parse-test ( accum word -- accum )
    literalize suffix!
    lexer get line>> suffix!
    \ experiment suffix! ; inline

<<

SYNTAX: TEST:
    scan-token
    [ create-word-in ]
    [ "(" ")" surround search '[ _ parse-test ] ] bi
    define-syntax ;

>>

: fake-unit-test ( quot -- test-failures )
    [
        "fake" current-test-file set
        V{ } clone test-failures set
        call
        test-failures get
    ] with-scope ; inline

PRIVATE>

: run-test-file ( path -- )
    dup current-test-file [
        test-failures get current-test-file get +test-failure+ delete-file-errors
        '[ _ run-file ] [
            restartable-tests? get
            [ dup compute-restarts empty? not ] [ f ] if
            [ rethrow ] [ file-failure ] if
        ] recover
    ] with-variable ;

SYMBOL: forget-tests?

<PRIVATE

: forget-tests ( files -- )
    forget-tests? get
    [ [ [ forget-source ] each ] with-compilation-unit ] [ drop ] if ;

: test-vocab ( vocab -- )
    lookup-vocab dup [
        dup source-loaded?>> [
            vocab-tests
            [ [ run-test-file ] each ]
            [ forget-tests ]
            bi
        ] [ drop ] if
    ] [ drop ] if ;

: test-vocabs ( vocabs -- ) [ test-vocab ] each ;

PRIVATE>

: with-test-file ( ..a quot: ( ..a path -- ..b ) -- ..b )
    '[ "" "" _ cleanup-unique-file ] with-temp-directory ; inline

: with-test-directory ( ..a quot: ( ..a -- ..b ) -- ..b )
    [ cleanup-unique-directory ] with-temp-directory ; inline

TEST: unit-test
TEST: must-infer-as
TEST: must-infer
TEST: must-fail-with
TEST: must-fail

M: test-failure error. ( error -- )
    {
        [ error-location print nl ]
        [ asset>> [ experiment. nl ] when* ]
        [ error>> error. ]
        [ continuation>> call>> callstack. ]
    } cleave ;

: :test-failures ( -- ) test-failures get errors. ;

: test ( prefix -- ) loaded-child-vocab-names test-vocabs ;

: test-all ( -- ) loaded-vocab-names filter-don't-test test-vocabs ;

: test-main ( -- )
    command-line get [ [ load ] [ test ] bi ] each ;

MAIN: test-main
