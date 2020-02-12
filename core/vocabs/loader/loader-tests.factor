USING: accessors compiler.units continuations debugger
definitions eval io.streams.string kernel math namespaces parser
prettyprint sequences sets source-files system tools.test vocabs
vocabs.files vocabs.loader vocabs.metadata vocabs.parser
vocabs.refresh words ;
IN: vocabs.loader.tests

! This vocab should not exist, but just in case...
{ } [
    [
        "vocabs.loader.test" forget-vocab
    ] with-compilation-unit
] unit-test

{ T{ vocab-link f "vocabs.loader.test" } }
[ "vocabs.loader.test" >vocab-link ] unit-test

{ t }
[ "kernel" >vocab-link "kernel" lookup-vocab = ] unit-test

IN: vocabs.loader.test.2

: hello ( -- ) ;

MAIN: hello

IN: vocabs.loader.tests

{ } [
    "vocabs.loader.test.2" run
    "vocabs.loader.test.2" lookup-vocab run
    "vocabs.loader.test.2" <vocab-link> run
] unit-test

[
    "resource:core/vocabs/loader/test/a/a.factor" forget-source
    "vocabs.loader.test.a" forget-vocab
] with-compilation-unit

0 "count-me" set-global

2 [
    [ "vocabs.loader.test.a" require ] must-fail

    [ f ] [ "vocabs.loader.test.a" lookup-vocab source-loaded?>> ] unit-test

    [ t ] [
        "resource:core/vocabs/loader/test/a/a.factor"
        path>source-file definitions>>
        "v-l-t-a-hello" "vocabs.loader.test.a" lookup-word dup .
        swap first in?
    ] unit-test
] times

{ 2 } [ "count-me" get-global ] unit-test

[
    "IN: vocabs.loader.test.a v-l-t-a-hello"
    <string-reader>
    "resource:core/vocabs/loader/test/a/a.factor"
    parse-stream
] [ error>> error>> error>> no-word-error? ] must-fail-with

0 "count-me" set-global

{ } [
    [
        "vocabs.loader.test.b" forget-vocab
    ] with-compilation-unit
] unit-test

{ f } [ "vocabs.loader.test.b" vocab-files empty? ] unit-test

{ } [
    [
        "vocabs.loader.test.b" vocab-files
        [ forget-source ] each
    ] with-compilation-unit
] unit-test

[ "vocabs.loader.test.b" require ] must-fail

{ 1 } [ "count-me" get-global ] unit-test

{ } [
    [
        "bob" "vocabs.loader.test.b" create-word
        [ ] ( -- ) define-declared
    ] with-compilation-unit
] unit-test

{ } [ "vocabs.loader.test.b" refresh ] unit-test

{ 2 } [ "count-me" get-global ] unit-test

{ f } [ "fred" "vocabs.loader.test.b" lookup-word undefined-word? ] unit-test

{ } [
    [
        "vocabs.loader.test.b" vocab-files
        [ forget-source ] each
    ] with-compilation-unit
] unit-test

{ } [ "vocabs.loader.test.b" changed-vocab ] unit-test

{ } [ "vocabs.loader.test.b" refresh ] unit-test

{ 3 } [ "count-me" get-global ] unit-test

{ { "resource:core/kernel/kernel.factor" 1 } }
[ "kernel" <vocab-link> where ] unit-test

{ { "resource:core/kernel/kernel.factor" 1 } }
[ "kernel" lookup-vocab where ] unit-test

{ } [
    [
        "vocabs.loader.test.c" forget-vocab
        "vocabs.loader.test.d" forget-vocab
    ] with-compilation-unit
] unit-test

{ +done+ } [
    [ "vocabs.loader.test.d" require ] [ :1 ] recover
    "vocabs.loader.test.d" lookup-vocab source-loaded?>>
] unit-test

: forget-junk ( -- )
    [
        { "2" "a" "b" "d" "e" "f" }
        [
            "vocabs.loader.test." prepend forget-vocab
        ] each
    ] with-compilation-unit ;

forget-junk

{ { } } [
    "IN: xabbabbja" eval( -- ) "xabbabbja" vocab-files
] unit-test

[ "xabbabbja" forget-vocab ] with-compilation-unit

forget-junk

{ } [ [ "vocabs.loader.test.e" forget-vocab ] with-compilation-unit ] unit-test

0 "vocabs.loader.test.g" set-global

[
    "vocabs.loader.test.f" forget-vocab
    "vocabs.loader.test.g" forget-vocab
] with-compilation-unit

{ } [ "vocabs.loader.test.g" require ] unit-test

{ 1 } [ "vocabs.loader.test.g" get-global ] unit-test

[
    "vocabs.loader.test.h" forget-vocab
    "vocabs.loader.test.i" forget-vocab
] with-compilation-unit

{ } [ "vocabs.loader.test.h" require ] unit-test


[
    "vocabs.loader.test.j" forget-vocab
    "vocabs.loader.test.k" forget-vocab
] with-compilation-unit

{ } [ [ "vocabs.loader.test.j" require ] [ drop :1 ] recover ] unit-test

{ } [ "vocabs.loader.test.m" require ] unit-test
{ f } [ "vocabs.loader.test.n" lookup-vocab ] unit-test
{ } [ "vocabs.loader.test.o" require ] unit-test
{ t } [ "vocabs.loader.test.n" lookup-vocab >boolean ] unit-test

[
    "mno" [ "vocabs.loader.test." swap suffix forget-vocab ] each
] with-compilation-unit

{ } [ "vocabs.loader.test.o" require ] unit-test
{ f } [ "vocabs.loader.test.n" lookup-vocab ] unit-test
{ } [ "vocabs.loader.test.m" require ] unit-test
{ t } [ "vocabs.loader.test.n" lookup-vocab >boolean ] unit-test

{ f } [ "vocabs.loader.test.p" lookup-vocab ] unit-test
{ } [ "vocabs.loader.test.p.private" require ] unit-test
{ { "foo" } } [ "vocabs.loader.test.p" vocab-words [ name>> ] map ] unit-test

[
    "mnop" [ "vocabs.loader.test." swap suffix forget-vocab ] each
] with-compilation-unit

[ os unix? "windows" "unix" ? require ]
[ error>> unsupported-platform? ] must-fail-with
