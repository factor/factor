! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators command-line
compiler.units continuations debugger effects generalizations io
io.files.temp io.files.unique kernel lexer math math.functions
math.vectors namespaces parser parser.notes prettyprint prettyprint.config quotations sequences
sequences.generalizations source-files source-files.errors
source-files.errors.debugger splitting stack-checker summary
system tools.errors tools.time unicode vocabs vocabs.files
vocabs.hierarchy vocabs.hierarchy.private vocabs.loader
vocabs.metadata vocabs.parser vocabs.refresh words ;
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
    { icon "vocab:ui/tools/error-list/icons/unit-test-error.png" }
    { quot [ test-failures get ] }
} define-error-type

SYMBOL: silent-tests?
f silent-tests? set-global

SYMBOL: verbose-tests?
f verbose-tests? set-global

SYMBOL: restartable-tests?
t restartable-tests? set-global

: <test-failure> ( error experiment path line# -- test-failure )
    test-failure new
        swap >>line#
        swap >>path
        swap >>asset
        swap >>error
        error-continuation get >>continuation ;

SYMBOL: long-unit-tests-threshold
long-unit-tests-threshold [ 10,000,000,000 ] initialize

SYMBOL: long-unit-tests-enabled?
long-unit-tests-enabled? [ t ] initialize

<PRIVATE

TUPLE: test-results executed skipped ;
C: <test-results> test-results
SYMBOL: current-test-results
SYMBOL: fake-test?

: test-executed ( -- )
    current-test-results get [ [ 1 + ] change-executed drop ] when* ;

: test-skipped ( -- )
    current-test-results get
    [ [ 1 + ] change-skipped drop ]
    [ "Warning: test skipped!" print ] if* ;

:: notify-test-failed ( error experiment path line# -- )
    fake-test? get [
        path write ":" write line# pprint ": test failed: " write
        error summary print flush
    ] unless
    error experiment path line# <test-failure> test-failures get push
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

:: (must-not-fail) ( quot -- error/f failed? tested? )
    [ { } quot with-datastack drop f f ] [ t ] recover t ;

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

:: experiment ( word: ( -- error/f failed? tested? ) line# -- )
    word <experiment> :> e
    silent-tests? get not verbose-tests? get and [ e experiment. ] when
    word execute [
        test-executed
        [
            current-test-file get [
                e current-test-file get line# notify-test-failed
            ] [ rethrow ] if
        ] [ drop ] if
    ] [ 2drop test-skipped ] if ; inline

: parse-test ( accum word -- accum )
    literalize suffix!
    lexer get line>> suffix!
    \ experiment suffix! ; inline

<<

SYNTAX: DEFINE-TEST-WORD:
    scan-token
    [ create-word-in ]
    [ "(" ")" surround search '[ _ parse-test ] ] bi
    define-syntax ;

>>

: fake-unit-test ( quot -- test-failures )
    [
        "fake" current-test-file set
        t fake-test? set
        V{ } clone test-failures set
        call
        test-failures get
    ] with-scope notify-error-observers ; inline

PRIVATE>

<PRIVATE

: with-test-output ( ..a quot: ( ..a -- ..b ) -- ..b )
    verbose-tests? get silent-tests? get not and not
    parser-quiet? [ call ] with-variable ; inline

PRIVATE>

: run-test-file ( path -- )
    dup current-test-file [
        test-failures get current-test-file get +test-failure+ delete-file-errors
        [
            '[ _ [ run-file ] with-default-pprint-config ] [
                restartable-tests? get
                [ dup compute-restarts empty? not ] [ f ] if
                [ rethrow ] [ notify-test-file-failed ] if
            ] recover
        ] with-test-output
    ] with-variable ;

SYMBOL: forget-tests?

<PRIVATE

: forget-tests ( files -- )
    forget-tests? get
    [ [ [ forget-source ] each ] with-compilation-unit ] [ drop ] if ;

: possible-long-unit-tests ( vocab nanos -- )
    long-unit-tests-threshold get [
        dupd > long-unit-tests-enabled? get not and [
            swap
            "Warning: possible long unit test for " write
            vocab-name write " - " write
            1,000,000,000 /f pprint " seconds" print
        ] [ 2drop ] if
    ] [ 2drop ] if* ;

: test-vocab ( vocab -- )
    lookup-vocab [
        dup source-loaded?>> [
            dup vocab-tests [
                [ [ run-test-file ] each ]
                [ forget-tests ]
                bi
            ] benchmark possible-long-unit-tests
        ] [ drop ] if
    ] when* ;

: test-vocabs ( vocabs -- )
    [ don't-test? ] reject [ test-vocab ] each ;

:: test-results. ( -- )
    current-test-results get skipped>> :> skipped
    silent-tests? get [
        skipped 0 > [ skipped pprint " tests skipped." print ] when
    ] [
        current-test-results get executed>> pprint " tests run, " write
        skipped pprint " skipped, " write
        test-failures get length pprint " pending failures." print
    ] if flush ;

:: with-test-run ( label quot: ( -- ) -- )
    0 0 <test-results> current-test-results [
        silent-tests? get [
            "Testing " write label empty? [ "all loaded vocabularies" ] [ label ] if
            write "..." print flush
        ] unless
        [ quot call ] with-test-output
        test-results.
    ] with-variable ;

PRIVATE>

: with-test-file ( ..a quot: ( ..a path -- ..b ) -- ..b )
    '[ "" "" _ cleanup-unique-file ] with-temp-directory ; inline

: with-test-directory ( ..a quot: ( ..a -- ..b ) -- ..b )
    [ cleanup-unique-directory ] with-temp-directory ; inline

DEFINE-TEST-WORD: unit-test
DEFINE-TEST-WORD: unit-test~
DEFINE-TEST-WORD: unit-test-v~
DEFINE-TEST-WORD: unit-test-comparator
DEFINE-TEST-WORD: long-unit-test
DEFINE-TEST-WORD: must-infer-as
DEFINE-TEST-WORD: must-infer
DEFINE-TEST-WORD: must-fail-with
DEFINE-TEST-WORD: must-fail
DEFINE-TEST-WORD: must-not-fail

M: test-failure error. ( error -- )
    {
        [ error-location print nl ]
        [ asset>> [ t verbose-tests? [ experiment. nl ] with-variable ] when* ]
        [ error>> error. ]
        [ continuation>> call>> callstack. ]
    } cleave ;

: :test-failures ( -- ) test-failures get errors. ;

: test ( prefix -- )
    dup '[ _ loaded-child-vocab-names test-vocabs ] with-test-run ;

: test-all ( -- ) "" test ;

: test-root ( root -- )
    dup '[ _ "" vocabs-to-load test-vocabs ] with-test-run ;

: refresh-and-test ( prefix -- )
    dup '[ _ to-refresh [ do-refresh ] keepdd test-vocabs ] with-test-run ;

: refresh-and-test-all ( -- ) "" refresh-and-test ;

: test-main ( -- )
    command-line get
    "--fast" swap [ member? ] [ remove ] 2bi swap
    [ f long-unit-tests-enabled? set-global ] when
    "--verbose" swap [ member? ] [ remove ] 2bi swap
    [ t verbose-tests? set-global f silent-tests? set-global ] when
    "--quiet" swap [ member? ] [ remove ] 2bi swap
    [ t silent-tests? set-global ] when
    [
        [
            dup vocab-roots get member? [
                [ load-root ] [ test-root ] bi
            ] [
                [ load ] [ test ] bi
            ] if
        ] each
    ] with-test-output
    test-failures get empty?
    [ [ "==== FAILING TESTS" print flush :test-failures ] unless ]
    [ 0 1 ? exit ] bi ;

MAIN: test-main
