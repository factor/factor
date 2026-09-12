USING: assocs calendar concurrency.promises continuations
destructors eval io io.streams.string kernel locals math memory
namespaces parser sequences strings threads tools.annotations
tools.test tools.time ;
IN: tools.annotations.tests

: foo ( -- ) ;
\ foo watch

{ } [ foo ] unit-test

! erg's bug
GENERIC: some-generic ( a -- b )

M: integer some-generic 1 + ;

{ 4 } [ 3 some-generic ] unit-test

{ } [ \ some-generic watch ] unit-test

{ 4 } [ 3 some-generic ] unit-test

{ } [ "IN: tools.annotations.tests USE: math M: integer some-generic 1 - ;" eval( -- ) ] unit-test

{ 2 } [ 3 some-generic ] unit-test

{ } [ \ some-generic reset ] unit-test

{ 2 } [ 3 some-generic ] unit-test

! slava's bug
GENERIC: another-generic ( a -- b )

M: object another-generic ;

\ another-generic watch

{ } [ "IN: tools.annotations.tests GENERIC: another-generic ( a -- b )" eval( -- ) ] unit-test

{ } [ \ another-generic reset ] unit-test

{ "" } [ [ 3 another-generic drop ] with-string-writer ] unit-test

! reset should do the right thing for generic words
{ } [ \ another-generic watch ] unit-test

GENERIC: blah-generic ( a -- b )

M: string blah-generic ;

{ } [ M\ string blah-generic watch ] unit-test

{ "hi" } [ "hi" blah-generic ] unit-test

! See how well watch interacts with optimizations.
GENERIC: my-generic ( a -- b )
M: object my-generic ;

\ my-generic watch

: some-code ( -- )
    f my-generic drop ;

{ } [ some-code ] unit-test

! Recursive calls share elapsed time while retaining their invocation count.
: timed-recursion ( n -- n! )
    dup 1 > [ [ 1 - timed-recursion ] [ * ] bi ]
    [ 20 milliseconds sleep ] if ;

\ timed-recursion add-timing

{ 40320 t 8 } [
    H{ } clone word-timing [
        [ 8 timed-recursion ] benchmark
        \ timed-recursion word-timing get at first2
        [ >= ] dip
    ] with-variable
] unit-test

\ timed-recursion reset

: timed-error ( fail? -- )
    [ 20 milliseconds sleep "timed error" throw ] when ;

\ timed-error add-timing

{ t t t 2 } [| |
    H{ } clone word-timing [
        [ t timed-error ] [ drop ] recover
        \ timed-error word-timing get at first :> before
        before 0 >
        [ f timed-error ] benchmark :> elapsed
        \ timed-error word-timing get at first2
        [ before - [ 0 > ] [ elapsed <= ] bi ] dip
    ] with-variable
] unit-test

\ timed-error reset

! An inherited timing scope must not suppress a child's independent timing.
: timed-thread ( child? -- time )
    [ 20 milliseconds sleep 0 ] [
        <promise> dup '[ t timed-thread _ fulfill ] in-thread
        5 seconds ?promise-timeout drop
        \ timed-thread word-timing get at first
    ] if ;

\ timed-thread add-timing

{ t 2 } [
    H{ } clone word-timing [
        f timed-thread 0 >
        \ timed-thread word-timing get at second
    ] with-variable
] unit-test

\ timed-thread reset

! Make sure annotations work on primitives
\ gc reset
\ gc watch

{ f } [ [ [ gc ] with-error>output ] with-string-writer empty? ] unit-test

\ gc reset
