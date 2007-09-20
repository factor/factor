! Unit tests for vocabs.loader vocabulary
IN: temporary
USING: vocabs.loader tools.test continuations vocabs math
kernel arrays sequences namespaces io.streams.string
parser source-files words assocs tuples definitions
debugger ;

! This vocab should not exist, but just in case...
[ ] [ "vocabs.loader.test" forget-vocab ] unit-test

[ T{ vocab-link f "vocabs.loader.test" } ]
[ "vocabs.loader.test" f >vocab-link ] unit-test

[ t ]
[ "kernel" f >vocab-link "kernel" vocab = ] unit-test

! This vocab should not exist, but just in case...
[ ] [ "core" forget-vocab ] unit-test

2 [
    [ T{ no-vocab f "core" } ]
    [ [ "core" require ] catch ] unit-test
] times

[ f ] [ "core" vocab ] unit-test

[ t ] [
    "kernel" vocab-files
    "kernel" vocab vocab-files
    "kernel" f \ vocab-link construct-boa vocab-files
    3array all-equal?
] unit-test

IN: vocabs.loader.test.2

: hello 3 ;

MAIN: hello

IN: temporary

[ { 3 3 3 } ] [
    "vocabs.loader.test.2" run
    "vocabs.loader.test.2" vocab run
    "vocabs.loader.test.2" f \ vocab-link construct-boa run
    3array
] unit-test

"resource:core/vocabs/loader/test/a/a.factor" forget-source

"vocabs.loader.test.a" forget-vocab

0 "count-me" set-global

2 [
    [ "vocabs.loader.test.a" require ] unit-test-fails
    
    [ f ] [ "vocabs.loader.test.a" vocab-source-loaded? ] unit-test
    
    [ t ] [
        "resource:core/vocabs/loader/test/a/a.factor"
        source-file source-file-definitions dup USE: prettyprint .
        "v-l-t-a-hello" "vocabs.loader.test.a" lookup dup .
        swap key?
    ] unit-test
] times

[ 2 ] [ "count-me" get-global ] unit-test

[ t ] [
    [
        "IN: vocabs.loader.test.a v-l-t-a-hello"
        <string-reader>
        "resource:core/vocabs/loader/test/a/a.factor"
        parse-stream
    ] catch [ forward-error? ] is?
] unit-test

0 "count-me" set-global

[ ] [ "vocabs.loader.test.b" forget-vocab ] unit-test

[ ] [
    "vocabs.loader.test.b" vocab-files [
        forget-source
    ] each
] unit-test

[ "vocabs.loader.test.b" require ] unit-test-fails

[ 1 ] [ "count-me" get-global ] unit-test

[ ] [
    "bob" "vocabs.loader.test.b" create [ ] define-compound
] unit-test

[ ] [ "vocabs.loader.test.b" refresh ] unit-test

[ 2 ] [ "count-me" get-global ] unit-test

[ t ] [ "fred" "vocabs.loader.test.b" lookup compound? ] unit-test

[ ] [
    "vocabs.loader.test.b" vocab-files [
        forget-source
    ] each
] unit-test

[ ] [ "vocabs.loader.test.b" refresh ] unit-test

[ 3 ] [ "count-me" get-global ] unit-test

[ { "resource:core/kernel/kernel.factor" 1 } ]
[ "kernel" f \ vocab-link construct-boa where ] unit-test

[ { "resource:core/kernel/kernel.factor" 1 } ]
[ "kernel" vocab where ] unit-test

[ t ] [
    [ "vocabs.loader.test.d" require ] catch
    [ :1 ] when
    "vocabs.loader.test.d" vocab-source-loaded?
] unit-test

: forget-junk
    { "2" "a" "b" "d" "e" "f" }
    [ "vocabs.loader.test." swap append forget-vocab ] each ;

forget-junk

[ { } ] [
    "IN: xabbabbja" eval "xabbabbja" vocab-files
] unit-test

"xabbabbja" forget-vocab

"bootstrap.help" vocab [
    [
        "again" off
        
        [ "vocabs.loader.test.e" require ] catch drop
        
        [ 3 ] [ restarts get length ] unit-test
        
        [ ] [
            "again" get not restarts get length 3 = and [
                "again" on
                :2
            ] when
        ] unit-test
    ] with-scope
] when

forget-junk
