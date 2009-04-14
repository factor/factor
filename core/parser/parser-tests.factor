USING: arrays math parser tools.test kernel generic words
io.streams.string namespaces classes effects source-files assocs
sequences strings io.files io.pathnames definitions
continuations sorting classes.tuple compiler.units debugger
vocabs vocabs.loader accessors eval combinators lexer
vocabs.parser words.symbol multiline ;
IN: parser.tests

\ run-file must-infer

[
    [ 1 [ 2 [ 3 ] 4 ] 5 ]
    [ "1\n[\n2\n[\n3\n]\n4\n]\n5" eval ]
    unit-test

    [ t t f f ]
    [ "t t f f" eval ]
    unit-test

    [ "hello world" ]
    [ "\"hello world\"" eval ]
    unit-test

    [ "\n\r\t\\" ]
    [ "\"\\n\\r\\t\\\\\"" eval ]
    unit-test

    [ "hello world" ]
    [
        "IN: parser.tests : hello ( -- str ) \"hello world\" ;"
        eval "USE: parser.tests hello" eval
    ] unit-test

    [ ]
    [ "! This is a comment, people." eval ]
    unit-test

    ! Test escapes

    [ " " ]
    [ "\"\\u000020\"" eval ]
    unit-test

    [ "'" ]
    [ "\"\\u000027\"" eval ]
    unit-test

    ! Test EOL comments in multiline strings.
    [ "Hello" ] [ "#! This calls until-eol.\n\"Hello\"" eval ] unit-test

    [ word ] [ \ f class ] unit-test

    ! Test stack effect parsing

    : effect-parsing-test ( a b -- c ) + ;

    [ t ] [
        "effect-parsing-test" "parser.tests" lookup
        \ effect-parsing-test eq?
    ] unit-test

    [ T{ effect f { "a" "b" } { "c" } f } ]
    [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    : baz ( a b -- * ) 2array throw ;

    [ t ]
    [ \ baz "declared-effect" word-prop terminated?>> ]
    unit-test

    [ ] [ "IN: parser.tests USE: math : effect-parsing-test ( a b -- d ) - ;" eval ] unit-test

    [ t ] [
        "effect-parsing-test" "parser.tests" lookup
        \ effect-parsing-test eq?
    ] unit-test

    [ T{ effect f { "a" "b" } { "d" } f } ]
    [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    ! Funny bug
    [ 2 ] [ "IN: parser.tests : \0. ( -- x ) 2 ; \0." eval ] unit-test

    [ "IN: parser.tests : missing-- ( a b ) ;" eval ] must-fail

    ! These should throw errors
    [ "HEX: zzz" eval ] must-fail
    [ "OCT: 999" eval ] must-fail
    [ "BIN: --0" eval ] must-fail

    ! Another funny bug
    [ t ] [
        [
            "scratchpad" in set
            { "scratchpad" "arrays" } set-use
            [
                ! This shouldn't modify in/use in the outer scope!
            ] with-file-vocabs

            use get { "scratchpad" "arrays" } set-use use get =
        ] with-scope
    ] unit-test
    DEFER: foo

    "IN: parser.tests USING: math prettyprint ; SYNTAX: foo 2 2 + . ;" eval

    [ ] [ "USE: parser.tests foo" eval ] unit-test

    "IN: parser.tests USING: math prettyprint ; : foo ( -- ) 2 2 + . ;" eval

    [ t ] [
        "USE: parser.tests \\ foo" eval
        "foo" "parser.tests" lookup eq?
    ] unit-test

    ! Test smudging

    [ 1 ] [
        "IN: parser.tests : smudge-me ( -- ) ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file definitions>> first assoc-size
    ] unit-test

    [ t ] [ "smudge-me" "parser.tests" lookup >boolean ] unit-test

    [ ] [
        "IN: parser.tests : smudge-me-more ( -- ) ;" <string-reader> "foo"
        parse-stream drop
    ] unit-test

    [ t ] [ "smudge-me-more" "parser.tests" lookup >boolean ] unit-test
    [ f ] [ "smudge-me" "parser.tests" lookup >boolean ] unit-test

    [ 3 ] [
        "IN: parser.tests USING: math strings ; GENERIC: smudge-me ( a -- b ) M: integer smudge-me ; M: string smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file definitions>> first assoc-size
    ] unit-test

    [ 1 ] [
        "IN: parser.tests USING: arrays ; M: array smudge-me ;" <string-reader> "bar"
        parse-stream drop

        "bar" source-file definitions>> first assoc-size
    ] unit-test

    [ 2 ] [
        "IN: parser.tests USING: math strings ; GENERIC: smudge-me ( a -- b ) M: integer smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file definitions>> first assoc-size
    ] unit-test
    
    [ t ] [
        array "smudge-me" "parser.tests" lookup order memq?
    ] unit-test
    
    [ t ] [
        integer "smudge-me" "parser.tests" lookup order memq?
    ] unit-test
    
    [ f ] [
        string "smudge-me" "parser.tests" lookup order memq?
    ] unit-test

    [ ] [
        "IN: parser.tests USE: math 2 2 +" <string-reader> "a"
        parse-stream drop
    ] unit-test
    
    [ t ] [
        "a" <pathname> \ + usage member?
    ] unit-test

    [ ] [
        "IN: parser.tests USE: math 2 2 -" <string-reader> "a"
        parse-stream drop
    ] unit-test
    
    [ f ] [
        "a" <pathname> \ + usage member?
    ] unit-test
    
    [ ] [
        "a" source-files get delete-at
        2 [
            "IN: parser.tests DEFER: x : y ( -- ) x ; : x ( -- ) y ;"
            <string-reader> "a" parse-stream drop
        ] times
    ] unit-test
    
    "a" source-files get delete-at

    [
        "IN: parser.tests : x ( -- ) ; : y ( -- * ) 3 throw ; this is an error"
        <string-reader> "a" parse-stream
    ] [ source-file-error? ] must-fail-with

    [ t ] [
        "y" "parser.tests" lookup >boolean
    ] unit-test

    [ f ] [
        "IN: parser.tests : x ( -- ) ;"
        <string-reader> "a" parse-stream drop
        
        "y" "parser.tests" lookup
    ] unit-test

    ! Test new forward definition logic
    [ ] [
        "IN: axx : axx ( -- ) ;"
        <string-reader> "axx" parse-stream drop
    ] unit-test

    [ ] [
        "USE: axx IN: bxx : bxx ( -- ) ; : cxx ( -- ) axx bxx ;"
        <string-reader> "bxx" parse-stream drop
    ] unit-test

    ! So we move the bxx word to axx...
    [ ] [
        "IN: axx : axx ( -- ) ; : bxx ( -- ) ;"
        <string-reader> "axx" parse-stream drop
    ] unit-test

    [ t ] [ "bxx" "axx" lookup >boolean ] unit-test

    ! And reload the file that uses it...
    [ ] [
        "USE: axx IN: bxx ( -- ) : cxx ( -- ) axx bxx ;"
        <string-reader> "bxx" parse-stream drop
    ] unit-test
    
    ! And hope not to get a forward-error!

    ! Turning a generic into a non-generic could cause all
    ! kinds of funnyness
    [ ] [
        "IN: ayy USE: kernel GENERIC: ayy ( a -- b ) M: object ayy ;"
        <string-reader> "ayy" parse-stream drop
    ] unit-test

    [ ] [
        "IN: ayy USE: kernel : ayy ( -- ) ;"
        <string-reader> "ayy" parse-stream drop
    ] unit-test

    [ ] [
        "IN: azz TUPLE: my-class ; GENERIC: a-generic ( a -- b )"
        <string-reader> "azz" parse-stream drop
    ] unit-test

    [ ] [
        "USE: azz M: my-class a-generic ;"
        <string-reader> "azz-2" parse-stream drop
    ] unit-test

    [ ] [
        "IN: azz GENERIC: a-generic ( a -- b )"
        <string-reader> "azz" parse-stream drop
    ] unit-test

    [ ] [
        "USE: azz USE: math M: integer a-generic ;"
        <string-reader> "azz-2" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests : <bogus-error> ( -- ) ; : bogus ( -- ) <bogus-error> ;"
        <string-reader> "bogus-error" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: bogus-error ; C: <bogus-error> bogus-error : bogus ( -- ) <bogus-error> ;"
        <string-reader> "bogus-error" parse-stream drop
    ] unit-test

    ! Problems with class predicates -vs- ordinary words
    [ ] [
        "IN: parser.tests TUPLE: killer ;"
        <string-reader> "removing-the-predicate" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests GENERIC: killer? ( a -- b )"
        <string-reader> "removing-the-predicate" parse-stream drop
    ] unit-test
    
    [ t ] [
        "killer?" "parser.tests" lookup >boolean
    ] unit-test

    [
        "IN: parser.tests TUPLE: another-pred-test ; GENERIC: another-pred-test? ( a -- b )"
        <string-reader> "removing-the-predicate" parse-stream
    ] [ error>> error>> error>> redefine-error? ] must-fail-with

    [
        "IN: parser.tests TUPLE: class-redef-test ; TUPLE: class-redef-test ;"
        <string-reader> "redefining-a-class-1" parse-stream
    ] [ error>> error>> error>> redefine-error? ] must-fail-with

    [ ] [
        "IN: parser.tests TUPLE: class-redef-test ; SYMBOL: class-redef-test"
        <string-reader> "redefining-a-class-2" parse-stream drop
    ] unit-test

    [
        "IN: parser.tests TUPLE: class-redef-test ; SYMBOL: class-redef-test : class-redef-test ( -- ) ;"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ error>> error>> error>> redefine-error? ] must-fail-with

    [ ] [
        "IN: parser.tests TUPLE: class-fwd-test ;"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] unit-test

    [
        "IN: parser.tests \\ class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ error>> error>> error>> no-word-error? ] must-fail-with

    [ ] [
        "IN: parser.tests TUPLE: class-fwd-test ; SYMBOL: class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] unit-test

    [
        "IN: parser.tests \\ class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ error>> error>> error>> no-word-error? ] must-fail-with

    [
        "IN: parser.tests : foo ( -- ) ; TUPLE: foo ;"
        <string-reader> "redefining-a-class-4" parse-stream drop
    ] [ error>> error>> error>> redefine-error? ] must-fail-with

    [ ] [
        "IN: parser.tests : foo ( x y -- z ) 1 2 ; : bar ( a -- b ) ;" eval
    ] unit-test

    [
        "IN: parser.tests : foo ( x y -- z) 1 2 ; : bar ( a -- b ) ;" eval
    ] must-fail
] with-file-vocabs

[ ] [
    "IN: parser.tests USE: kernel PREDICATE: foo < object ( x -- y ) ;" eval
] unit-test

[ t ] [
    "foo?" "parser.tests" lookup word eq?
] unit-test

[ ] [
    [
        "redefining-a-class-5" forget-source
        "redefining-a-class-6" forget-source
        "redefining-a-class-7" forget-source
    ] with-compilation-unit
] unit-test

2 [
    [ ] [
        "IN: parser.tests TUPLE: foo ; GENERIC: foo ( a -- b )"
        <string-reader> "redefining-a-class-5" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests M: f foo ;"
        <string-reader> "redefining-a-class-6" parse-stream drop
    ] unit-test

    [ f ] [ f "foo" "parser.tests" lookup execute ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: foo ; GENERIC: foo ( a -- b )"
        <string-reader> "redefining-a-class-5" parse-stream drop
    ] unit-test

    [ f ] [ f "foo" "parser.tests" lookup execute ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: foo ; GENERIC: foo ( a -- b )"
    <string-reader> "redefining-a-class-7" parse-stream drop
    ] unit-test

    [ f ] [ f "foo" "parser.tests" lookup execute ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: foo ;"
        <string-reader> "redefining-a-class-7" parse-stream drop
    ] unit-test

    [ t ] [ "foo" "parser.tests" lookup symbol? ] unit-test
] times

[ "vocab:parser/test/assert-depth.factor" run-file ] must-fail

2 [
    [ ] [
        "IN: parser.tests DEFER: d-f-s d-f-s SYMBOL: d-f-s d-f-s"
        <string-reader> "d-f-s-test" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests DEFER: d-f-s d-f-s FORGET: d-f-s SYMBOL: d-f-s d-f-s"
        <string-reader> "d-f-s-test" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests DEFER: d-f-s d-f-s SYMBOL: d-f-s d-f-s"
        <string-reader> "d-f-s-test" parse-stream drop
    ] unit-test
] times

[ ] [
    [ "this-better-not-exist" forget-vocab ] with-compilation-unit
] unit-test

[
    "USE: this-better-not-exist" eval
] must-fail

[ ": foo ;" eval ] [ error>> error>> no-current-vocab? ] must-fail-with

[ 92 ] [ "CHAR: \\" eval ] unit-test
[ 92 ] [ "CHAR: \\\\" eval ] unit-test

[ ] [
    {
        "IN: parser.tests"
        "USING: math arrays ;"
        "GENERIC: change-combination ( a -- b )"
        "M: integer change-combination 1 ;"
        "M: array change-combination 2 ;"
    } "\n" join <string-reader> "change-combination-test" parse-stream drop
] unit-test

[ ] [
    {
        "IN: parser.tests"
        "USING: math arrays ;"
        "GENERIC# change-combination 1 ( a -- b )"
        "M: integer change-combination 1 ;"
        "M: array change-combination 2 ;"
    } "\n" join <string-reader> "change-combination-test" parse-stream drop
] unit-test

[ 2 ] [
    "change-combination" "parser.tests" lookup
    "methods" word-prop assoc-size
] unit-test

[ ] [
    2 [
        "IN: parser.tests DEFER: twice-fails FORGET: twice-fails MIXIN: twice-fails"
        <string-reader> "twice-fails-test" parse-stream drop
    ] times
] unit-test

[ [ ] ] [
    "IN: parser.tests : staging-problem-test-1 ( -- ) 1 ; : staging-problem-test-2 ( -- ) staging-problem-test-1 ;"
    <string-reader> "staging-problem-test" parse-stream
] unit-test

[ t ] [ "staging-problem-test-1" "parser.tests" lookup >boolean ] unit-test

[ t ] [ "staging-problem-test-2" "parser.tests" lookup >boolean ] unit-test

[ [ ] ] [
    "IN: parser.tests << : staging-problem-test-1 ( -- ) 1 ; >> : staging-problem-test-2 ( -- ) staging-problem-test-1 ;"
    <string-reader> "staging-problem-test" parse-stream
] unit-test

[ t ] [ "staging-problem-test-1" "parser.tests" lookup >boolean ] unit-test

[ t ] [ "staging-problem-test-2" "parser.tests" lookup >boolean ] unit-test

[ "DEFER: blahy" eval ] [ error>> error>> no-current-vocab? ] must-fail-with

[
    "IN: parser.tests SYNTAX: blahy ; FORGET: blahy" eval
] [
    error>> staging-violation?
] must-fail-with

! Bogus error message
DEFER: blahy

[ "IN: parser.tests USE: kernel TUPLE: blahy < tuple ; : blahy ( -- ) ; TUPLE: blahy < tuple ; : blahy ( -- ) ;" eval ]
[ error>> error>> def>> \ blahy eq? ] must-fail-with

[ ] [ f lexer set f file set "Hello world" note. ] unit-test

[ "CHAR: \\u9999999999999" eval ] must-fail

SYMBOLS: a b c ;

[ a ] [ a ] unit-test
[ b ] [ b ] unit-test
[ c ] [ c ] unit-test

DEFER: blah

[ ] [ "IN: parser.tests GENERIC: blah ( -- )" eval ] unit-test
[ ] [ "IN: parser.tests SYMBOLS: blah ;" eval ] unit-test

[ f ] [ \ blah generic? ] unit-test
[ t ] [ \ blah symbol? ] unit-test

DEFER: blah1

[ "IN: parser.tests SINGLETONS: blah1 blah1 blah1 ;" eval ]
[ error>> error>> def>> \ blah1 eq? ]
must-fail-with

IN: qualified.tests.foo
: x ( -- a ) 1 ;
: y ( -- a ) 5 ;
IN: qualified.tests.bar
: x ( -- a ) 2 ;
: y ( -- a ) 4 ;
IN: qualified.tests.baz
: x ( -- a ) 3 ;

QUALIFIED: qualified.tests.foo
QUALIFIED: qualified.tests.bar
[ 1 2 3 ] [ qualified.tests.foo:x qualified.tests.bar:x x ] unit-test

QUALIFIED-WITH: qualified.tests.bar p
[ 2 ] [ p:x ] unit-test

RENAME: x qualified.tests.baz => y
[ 3 ] [ y ] unit-test

FROM: qualified.tests.baz => x ;
[ 3 ] [ x ] unit-test
[ 3 ] [ y ] unit-test

EXCLUDE: qualified.tests.bar => x ;
[ 3 ] [ x ] unit-test
[ 4 ] [ y ] unit-test

[ "IN: qualified.tests FROM: qualified.tests => doesnotexist ;" eval ]
[ error>> no-word-error? ] must-fail-with

[ "IN: qualified.tests RENAME: doesnotexist qualified.tests => blahx" eval ]
[ error>> no-word-error? ] must-fail-with

! Two similar bugs

! Replace : def with something in << >>
/* [ [ ] ] [
    "IN: parser.tests : was-once-a-word-bug ( -- ) ;"
    <string-reader> "was-once-a-word-test" parse-stream
] unit-test

[ t ] [ "was-once-a-word-bug" "parser.tests" lookup >boolean ] unit-test

[ [ ] ] [
    "IN: parser.tests USE: words << \"was-once-a-word-bug\" \"parser.tests\" create [ ] (( -- )) define-declared >>"
    <string-reader> "was-once-a-word-test" parse-stream
] unit-test

[ t ] [ "was-once-a-word-bug" "parser.tests" lookup >boolean ] unit-test */

! Replace : def with DEFER:
[ [ ] ] [
    "IN: parser.tests : is-not-deferred ( -- ) ;"
    <string-reader> "is-not-deferred" parse-stream
] unit-test

[ t ] [ "is-not-deferred" "parser.tests" lookup >boolean ] unit-test
[ f ] [ "is-not-deferred" "parser.tests" lookup deferred? ] unit-test

[ [ ] ] [
    "IN: parser.tests DEFER: is-not-deferred"
    <string-reader> "is-not-deferred" parse-stream
] unit-test

[ t ] [ "is-not-deferred" "parser.tests" lookup >boolean ] unit-test
[ t ] [ "is-not-deferred" "parser.tests" lookup deferred? ] unit-test
