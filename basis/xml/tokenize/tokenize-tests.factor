USING: accessors compiler.test compiler.units continuations
io.streams.string kernel math namespaces sequences strings
tools.test xml.state xml.tokenize ;
IN: xml.tokenize.tests

: with-unoptimized-scanners ( quot -- )
    [ { (parse-char) (skip-until) } [ decompile ] each call ]
    [ { (parse-char) (skip-until) } compile ] finally ; inline

! #3046: GIR files contain tokens long enough to overflow recursive
! locals when the optimizing compiler is disabled.
{ t } [
    [
        100000 CHAR: x <string> dup "<" append <string-reader> [
            [ CHAR: < = ] \ parse-char def>> call( quot -- string )
        ] with-state =
    ] with-unoptimized-scanners
] unit-test

{ "" f } [
    [
        "" <string-reader> [
            [ CHAR: < = ] \ parse-char def>> call( quot -- string )
            get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

{ "" CHAR: z } [
    [
        "<z" <string-reader> [
            [ CHAR: < = ] \ parse-char def>> call( quot -- string )
            get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

{ "abc" f } [
    [
        "abc" <string-reader> [
            [ CHAR: < = ] \ parse-char def>> call( quot -- string )
            get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

{ "a&bA" CHAR: z } [
    [
        "a&amp;b&#65;<z" <string-reader> [
            [ CHAR: < = ] \ parse-char def>> call( quot -- string )
            get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

{ "expanded" CHAR: z } [
    [
        "%entity;<z" <string-reader> [
            t in-dtd? set
            H{ { "entity" "expanded" } } pe-table set
            [ CHAR: < = ] \ parse-char def>> call( quot -- string )
            get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

! Preserve values threaded through the predicate and leave the matching
! delimiter for the caller, including after a long run of whitespace.
{ 100001 CHAR: x } [
    [
        100000 CHAR: \s <string> "x" append <string-reader> [
            0 [ [ 1 + ] dip CHAR: x = ]
            \ skip-until def>> call( n quot -- n ) get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

{ 0 f } [
    [
        "" <string-reader> [
            0 [ [ 1 + ] dip CHAR: x = ]
            \ skip-until def>> call( n quot -- n ) get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test

{ 1 CHAR: x } [
    [
        "xyz" <string-reader> [
            0 [ [ 1 + ] dip CHAR: x = ]
            \ skip-until def>> call( n quot -- n ) get-char
        ] with-state
    ] with-unoptimized-scanners
] unit-test
