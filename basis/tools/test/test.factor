! Copyright (C) 2003, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators compiler.units
continuations debugger effects fry generalizations
sequences.generalizations io io.files io.styles kernel lexer
locals macros math.parser namespaces parser vocabs.parser
prettyprint quotations sequences source-files splitting
stack-checker summary unicode.case vectors vocabs vocabs.loader
vocabs.files vocabs.metadata words tools.errors
source-files.errors source-files.errors.debugger io.streams.string
make compiler.errors ;
IN: tools.test

TUPLE: test-failure < source-file-error continuation ;

SYMBOL: +test-failure+

M: test-failure error-type drop +test-failure+ ;

SYMBOL: test-failures

test-failures [ V{ } clone ] initialize

T{ error-type
   { type +test-failure+ }
   { word ":test-failures" }
   { plural "unit test failures" }
   { icon "vocab:ui/tools/error-list/icons/unit-test-error.tiff" }
   { quot [ test-failures get ] }
} define-error-type

SYMBOL: verbose-tests?
t verbose-tests? set-global

<PRIVATE

: <test-failure> ( error experiment file line# -- triple )
    test-failure new
        swap >>line#
        swap >>file
        swap >>asset
        swap >>error
        error-continuation get >>continuation ;

: failure ( error experiment file line# -- )
    "--> test failed!" print
    <test-failure> test-failures get push
    notify-error-observers ;

SYMBOL: file

: file-failure ( error -- )
    [ f file get ] keep error-line failure ;

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

MACRO: <experiment> ( word -- )
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
        file get [
            e file get line# failure
        ] [ rethrow ] if
    ] [ drop ] if ; inline

: parse-test ( accum word -- accum )
    literalize suffix!
    lexer get line>> suffix!
    \ experiment suffix! ; inline

<<

SYNTAX: TEST:
    scan-token
    [ create-in ]
    [ "(" ")" surround search '[ _ parse-test ] ] bi
    define-syntax ;

>>

: fake-unit-test ( quot -- test-failures )
    [
        "fake" file set
        V{ } clone test-failures set
        call
        test-failures get
    ] with-scope ; inline

PRIVATE>

: run-test-file ( path -- )
    dup file [
        test-failures get file get +test-failure+ delete-file-errors
        '[ _ run-file ] [ file-failure ] recover
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
        [ continuation>> traceback-link. ]
    } cleave ;

: :test-failures ( -- ) test-failures get errors. ;

: test ( prefix -- ) child-vocabs test-vocabs ;

: test-all ( -- ) vocabs filter-don't-test test-vocabs ;

