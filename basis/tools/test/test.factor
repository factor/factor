! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators command-line
compiler.units constructors continuations debugger effects fry
generalizations io io.files.temp io.files.unique
io.streams.string kernel lexer locals macros math.functions
math.vectors namespaces parser prettyprint quotations sequences
sequences.generalizations source-files source-files.errors
source-files.errors.debugger splitting stack-checker summary
system tools.errors unicode vocabs vocabs.files vocabs.metadata
vocabs.parser words ;
FROM: vocabs.hierarchy => load ;
IN: tools.test

TUPLE: test-failure < source-file-error continuation ;

SYMBOL: +test-failure+

M: test-failure error-type drop +test-failure+ ;

INITIALIZED-SYMBOL: test-failures [ V{ } clone ]

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

INITIALIZED-SYMBOL: long-unit-tests-enabled? [ t ]

<PRIVATE

: notify-test-failed ( error experiment path line# -- )
    "--> test failed!" print
    <test-failure> test-failures get push
    notify-error-observers ;

SYMBOL: current-test-file

: notify-test-file-failed ( error -- )
    [ f current-test-file get ] keep error-line notify-test-failed ;

:: (unit-test) ( output input -- error/f failed? tested? )
    [ { } input with-datastack output assert-sequence= f f ] [ t ] recover t ;

: (long-unit-test) ( output input -- error/f failed? tested? )
    long-unit-tests-enabled? get [ (unit-test) ] [ 2drop f f f ] if ;

: (unit-test-comparator) ( output input comparator -- error/f failed? tested? )
    swapd '[
        { } _ with-datastack _ >quotation
        [ 3dup @ [ 3drop t ] [ drop assert ] if ] compose
        with-datastack first dup not
    ] [ t ] recover t ; inline

: (unit-test~) ( output input -- error/f failed? tested? )
    [ ~ ] (unit-test-comparator) ;

: (unit-test-v~) ( output input -- error/f failed? tested? )
    [ v~ ] (unit-test-comparator) ;

: short-effect ( effect -- pair )
    [ in>> length ] [ out>> length ] bi 2array ;

:: (must-infer-as) ( effect quot -- error/f failed? tested? )
    [ quot infer short-effect effect assert= f f ] [ t ] recover t ;

:: (must-infer) ( quot -- error/f failed? tested? )
    [ quot infer drop f f ] [ t ] recover t ;

SINGLETON: did-not-fail

M: did-not-fail summary drop "Did not fail" ;

:: (must-fail-with) ( quot pred -- error/f failed? tested? )
    [ { } quot with-datastack drop did-not-fail t ]
    [ dup pred call( error -- ? ) [ drop f f ] [ t ] if ] recover t ;

:: (must-fail) ( quot -- error/f failed? tested? )
    [ { } quot with-datastack drop did-not-fail t ] [ drop f f ] recover t ;

: experiment-title ( word -- string )
    "(" ?head drop ")" ?tail drop
    H{ { char: - char: \s } } substitute >title ;

MACRO: <experiment> ( word -- quot )
    [ stack-effect in>> length dup ]
    [ name>> experiment-title ] bi
    '[ _ ndup _ narray _ prefix ] ;

TUPLE: new-unit-test-failed error test expected path line# ;

TUPLE: new-experiment test expected ;

: <new-experiment> ( test expected -- new-experiment )
    new-experiment new
        swap >>expected
        swap >>test ; inline

: new-unit-test-failed>experiment ( new-unit-test-failed -- new-experiment )
    [ test>> ] [ expected>> ] bi <new-experiment> ;

GENERIC: experiment. ( obj -- )

M: array experiment. ( seq -- )
    [ first write ": " write ]
    [ rest verbose-tests? get [ . ] [ short. ] if flush ] bi ;

M: new-experiment experiment. ( seq -- )
    "UNIT-TEST: " write
    [ test>> verbose-tests? get [ pprint ] [ pprint-short ] if flush bl ]
    [ expected>> verbose-tests? get [ pprint ] [ pprint-short ] if nl flush ] bi ;

:: experiment ( word: ( -- error/f failed? tested? ) line# -- )
    word <experiment> :> e
    e experiment.
    word execute [
        [
            current-test-file get [
                e current-test-file get line# notify-test-failed
            ] [ rethrow ] if
        ] [ drop ] if
    ] [ 2drop "Warning: test skipped!" print ] if ; inline

: parse-test ( accum word -- accum )
    literalize suffix!
    lexer get line>> suffix!
    \ experiment suffix! ; inline

<<

SYNTAX: \TEST:
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
    ] with-scope notify-error-observers ; inline

PRIVATE>

: run-test-file ( path -- )
    dup current-test-file [
        test-failures get current-test-file get +test-failure+ delete-file-errors
        '[ _ run-file ] [
            restartable-tests? get
            [ dup compute-restarts empty? not ] [ f ] if
            [ rethrow ] [ notify-test-file-failed ] if
        ] recover
    ] with-variable ;

SYMBOL: forget-tests?

<PRIVATE

: forget-tests ( files -- )
    forget-tests? get
    [ [ [ forget-source ] each ] with-compilation-unit ] [ drop ] if ;

PRIVATE>

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

: with-test-file ( ..a quot: ( ..a path -- ..b ) -- ..b )
    '[ "" "" _ cleanup-unique-file ] with-temp-directory ; inline

: with-test-directory ( ..a quot: ( ..a -- ..b ) -- ..b )
    [ cleanup-unique-directory ] with-temp-directory ; inline

TEST: unit-test
TEST: unit-test~
TEST: unit-test-v~
TEST: unit-test-comparator
TEST: long-unit-test
TEST: must-infer-as
TEST: must-infer
TEST: must-fail-with
TEST: must-fail

: notify-new-test-failed ( new-unit-test-failed -- )
    {
        [ error>> ]
        [ new-unit-test-failed>experiment ]
        [ path>> ]
        [ line#>> ]
    } cleave notify-test-failed ;

SYNTAX: \UNIT-TEST:
    scan-object scan-object 2dup 2dup
    current-test-file get
    lexer get line>>
    '[
        _ _ <new-experiment> experiment.
        [ { } _ with-datastack _ assert-sequence= ]
        [
            _ _ _ _ \ new-unit-test-failed boa
            dup path>> [
                notify-new-test-failed
            ] [
                error>> rethrow
            ] if
        ] recover
    ] append! ;

TUPLE: unit-test-failed-section quot ;
CONSTRUCTOR: <unit-test-failed-section> unit-test-failed-section ( quot -- obj ) ;
SYMBOL: \UNIT-TEST-FAILED>
SYNTAX: \<UNIT-TEST-FAILED
    \ UNIT-TEST-FAILED> parse-until <unit-test-failed-section> suffix! ;

TUPLE: unit-test-code quot ;
CONSTRUCTOR: <unit-test-code> unit-test-code ( quot -- obj ) ;
SYNTAX: \UNIT-TEST-CODE: scan-object <unit-test-code> suffix! ;

TUPLE: got-stack stack ;
CONSTRUCTOR: <got-stack> got-stack ( stack -- obj ) ;
SYNTAX: \GOT-STACK: scan-object <got-stack> suffix! ;

TUPLE: expected-stack stack ;
CONSTRUCTOR: <expected-stack> expected-stack ( stack -- obj ) ;
SYNTAX: \EXPECTED-STACK: scan-object <expected-stack> suffix! ;

TUPLE: got-stdout string ;
CONSTRUCTOR: <got-stdout> got-stdout ( string -- obj ) ;
SYNTAX: \GOT-STDOUT: scan-object <got-stdout> suffix! ;

TUPLE: got-stderr string ;
CONSTRUCTOR: <got-stderr> got-stderr ( string -- obj ) ;
SYNTAX: \GOT-STDERR: scan-object <got-stderr> suffix! ;

TUPLE: expected-stdout string ;
CONSTRUCTOR: <expected-stdout> expected-stdout ( string -- obj ) ;
SYNTAX: \EXPECTED-STDOUT: scan-object <expected-stdout> suffix! ;

TUPLE: expected-stderr string ;
CONSTRUCTOR: <expected-stderr> expected-stderr ( string -- obj ) ;
SYNTAX: \EXPECTED-STDERR: scan-object <expected-stderr> suffix! ;

TUPLE: named-unit-test name test stack ;
CONSTRUCTOR: <named-unit-test> named-unit-test ( name test stack -- obj ) ;
SYNTAX: \NAMED-UNIT-TEST:
    scan-new-word scan-object scan-object <named-unit-test> suffix! ;

TUPLE: stdout-unit-test test string ;
CONSTRUCTOR: <stdout-unit-test> stdout-unit-test ( test string -- obj ) ;

: run-stdout-unit-test ( obj -- )
    [ test>> '[ _ with-string-writer ] call( -- string ) ]
    [ string>> ] bi assert-string= ; inline

SYNTAX: \STDOUT-UNIT-TEST:
    scan-object scan-object <stdout-unit-test> '[ _ run-stdout-unit-test ] append! ;

TUPLE: stderr-unit-test test string ;
CONSTRUCTOR: <stderr-unit-test> stderr-unit-test ( test string -- obj ) ;

: run-stderr-unit-test ( obj -- )
    [ test>> '[ _ with-error-string-writer ] call( -- string ) ]
    [ string>> ] bi assert-string= ; inline

SYNTAX: \STDERR-UNIT-TEST:
    scan-object scan-object <stderr-unit-test> '[ _ run-stderr-unit-test ] append! ;

M: test-failure error. ( error -- )
    {
        [ error-location print nl ]
        [ asset>> [ experiment. nl ] when* ]
        [ error>> error. ]
        [ continuation>> call>> callstack. ]
    } cleave ;

: :test-failures ( -- ) test-failures get errors. ;

: test ( prefix -- )
    loaded-child-vocab-names test-vocabs ;

: test-all ( -- )
    loaded-vocab-names [ don't-test? ] reject test-vocabs ;

: test-main ( -- )
    command-line get [ [ load ] [ test ] bi ] each
    test-failures get empty?
    [ [ "==== FAILING TESTS" print flush :test-failures ] unless ]
    [ 0 1 ? exit ] bi ;

MAIN: test-main
