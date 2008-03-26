USING: arrays math parser tools.test kernel generic words
io.streams.string namespaces classes effects source-files
assocs sequences strings io.files definitions continuations
sorting tuples compiler.units debugger vocabs vocabs.loader ;
IN: parser.tests

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
        "IN: parser.tests : hello \"hello world\" ;"
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
    [ \ baz "declared-effect" word-prop effect-terminated? ]
    unit-test

    [ ] [ "IN: parser.tests USE: math : effect-parsing-test ( a b -- d ) - ;" eval ] unit-test

    [ t ] [
        "effect-parsing-test" "parser.tests" lookup
        \ effect-parsing-test eq?
    ] unit-test

    [ T{ effect f { "a" "b" } { "d" } f } ]
    [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    [ ] [ "IN: parser.tests : effect-parsing-test ;" eval ] unit-test

    [ f ] [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    ! Funny bug
    [ 2 ] [ "IN: parser.tests : \0. 2 ; \0." eval ] unit-test

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

    "IN: parser.tests USING: math prettyprint ; : foo 2 2 + . ; parsing" eval

    [ ] [ "USE: parser.tests foo" eval ] unit-test

    "IN: parser.tests USING: math prettyprint ; : foo 2 2 + . ;" eval

    [ t ] [
        "USE: parser.tests \\ foo" eval
        "foo" "parser.tests" lookup eq?
    ] unit-test

    ! Test smudging

    [ 1 ] [
        "IN: parser.tests : smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test

    [ t ] [ "smudge-me" "parser.tests" lookup >boolean ] unit-test

    [ ] [
        "IN: parser.tests : smudge-me-more ;" <string-reader> "foo"
        parse-stream drop
    ] unit-test

    [ t ] [ "smudge-me-more" "parser.tests" lookup >boolean ] unit-test
    [ f ] [ "smudge-me" "parser.tests" lookup >boolean ] unit-test

    [ 3 ] [
        "IN: parser.tests USING: math strings ; GENERIC: smudge-me M: integer smudge-me ; M: string smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test

    [ 1 ] [
        "IN: parser.tests USING: arrays ; M: array smudge-me ;" <string-reader> "bar"
        parse-stream drop

        "bar" source-file source-file-definitions first assoc-size
    ] unit-test

    [ 2 ] [
        "IN: parser.tests USING: math strings ; GENERIC: smudge-me M: integer smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
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
            "IN: parser.tests DEFER: x : y x ; : x y ;"
            <string-reader> "a" parse-stream drop
        ] times
    ] unit-test
    
    "a" source-files get delete-at

    [
        "IN: parser.tests : x ; : y 3 throw ; this is an error"
        <string-reader> "a" parse-stream
    ] [ parse-error? ] must-fail-with

    [ t ] [
        "y" "parser.tests" lookup >boolean
    ] unit-test

    [ f ] [
        "IN: parser.tests : x ;"
        <string-reader> "a" parse-stream drop
        
        "y" "parser.tests" lookup
    ] unit-test

    ! Test new forward definition logic
    [ ] [
        "IN: axx : axx ;"
        <string-reader> "axx" parse-stream drop
    ] unit-test

    [ ] [
        "USE: axx IN: bxx : bxx ; : cxx axx bxx ;"
        <string-reader> "bxx" parse-stream drop
    ] unit-test

    ! So we move the bxx word to axx...
    [ ] [
        "IN: axx : axx ; : bxx ;"
        <string-reader> "axx" parse-stream drop
    ] unit-test

    [ t ] [ "bxx" "axx" lookup >boolean ] unit-test

    ! And reload the file that uses it...
    [ ] [
        "USE: axx IN: bxx : cxx axx bxx ;"
        <string-reader> "bxx" parse-stream drop
    ] unit-test
    
    ! And hope not to get a forward-error!

    ! Turning a generic into a non-generic could cause all
    ! kinds of funnyness
    [ ] [
        "IN: ayy USE: kernel GENERIC: ayy M: object ayy ;"
        <string-reader> "ayy" parse-stream drop
    ] unit-test

    [ ] [
        "IN: ayy USE: kernel : ayy ;"
        <string-reader> "ayy" parse-stream drop
    ] unit-test

    [ ] [
        "IN: azz TUPLE: my-class ; GENERIC: a-generic"
        <string-reader> "azz" parse-stream drop
    ] unit-test

    [ ] [
        "USE: azz M: my-class a-generic ;"
        <string-reader> "azz-2" parse-stream drop
    ] unit-test

    [ ] [
        "IN: azz GENERIC: a-generic"
        <string-reader> "azz" parse-stream drop
    ] unit-test

    [ ] [
        "USE: azz USE: math M: integer a-generic ;"
        <string-reader> "azz-2" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests : <bogus-error> ; : bogus <bogus-error> ;"
        <string-reader> "bogus-error" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: bogus-error ; C: <bogus-error> bogus-error : bogus <bogus-error> ;"
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
        "IN: parser.tests TUPLE: another-pred-test ; GENERIC: another-pred-test?"
        <string-reader> "removing-the-predicate" parse-stream
    ] [ [ redefine-error? ] is? ] must-fail-with

    [
        "IN: parser.tests TUPLE: class-redef-test ; TUPLE: class-redef-test ;"
        <string-reader> "redefining-a-class-1" parse-stream
    ] [ [ redefine-error? ] is? ] must-fail-with

    [ ] [
        "IN: parser.tests TUPLE: class-redef-test ; SYMBOL: class-redef-test"
        <string-reader> "redefining-a-class-2" parse-stream drop
    ] unit-test

    [
        "IN: parser.tests TUPLE: class-redef-test ; SYMBOL: class-redef-test : class-redef-test ;"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ [ redefine-error? ] is? ] must-fail-with

    [ ] [
        "IN: parser.tests TUPLE: class-fwd-test ;"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] unit-test

    [
        "IN: parser.tests \\ class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ [ no-word? ] is? ] must-fail-with

    [ ] [
        "IN: parser.tests TUPLE: class-fwd-test ; SYMBOL: class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] unit-test

    [
        "IN: parser.tests \\ class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ [ no-word? ] is? ] must-fail-with

    [
        "IN: parser.tests : foo ; TUPLE: foo ;"
        <string-reader> "redefining-a-class-4" parse-stream drop
    ] [ [ redefine-error? ] is? ] must-fail-with

    [ ] [
        "IN: parser.tests : foo ( x y -- z ) 1 2 ; : bar ( a -- b ) ;" eval
    ] unit-test

    [
        "IN: parser.tests : foo ( x y -- z) 1 2 ; : bar ( a -- b ) ;" eval
    ] must-fail
] with-file-vocabs

[
    << file get parsed >> file set

    : ~a ;

    DEFER: ~b

    "IN: parser.tests : ~b ~a ;" <string-reader>
    "smudgy" parse-stream drop

    : ~c ;
    : ~d ;

    { H{ { ~a ~a } { ~b ~b } { ~c ~c } { ~d ~d } } H{ } } old-definitions set
    
    { H{ { ~b ~b } { ~d ~d } } H{ } } new-definitions set
    
    [ V{ ~b } { ~a } { ~a ~c } ] [
        smudged-usage
        natural-sort
    ] unit-test
] with-scope

[
    << file get parsed >> file set

    GENERIC: ~e

    : ~f ~e ;

    : ~g ;

    { H{ { ~e ~e } { ~f ~f } { ~g ~g } } H{ } } old-definitions set
    
    { H{ { ~g ~g } } H{ } } new-definitions set

    [ V{ } { } { ~e ~f } ]
    [ smudged-usage natural-sort ]
    unit-test
] with-scope

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
        "IN: parser.tests TUPLE: foo ; GENERIC: foo"
        <string-reader> "redefining-a-class-5" parse-stream drop
    ] unit-test

    [ ] [
        "IN: parser.tests M: f foo ;"
        <string-reader> "redefining-a-class-6" parse-stream drop
    ] unit-test

    [ f ] [ f "foo" "parser.tests" lookup execute ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: foo ; GENERIC: foo"
        <string-reader> "redefining-a-class-5" parse-stream drop
    ] unit-test

    [ f ] [ f "foo" "parser.tests" lookup execute ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: foo ; GENERIC: foo"
    <string-reader> "redefining-a-class-7" parse-stream drop
    ] unit-test

    [ f ] [ f "foo" "parser.tests" lookup execute ] unit-test

    [ ] [
        "IN: parser.tests TUPLE: foo ;"
        <string-reader> "redefining-a-class-7" parse-stream drop
    ] unit-test

    [ t ] [ "foo" "parser.tests" lookup symbol? ] unit-test
] times

[ "resource:core/parser/test/assert-depth.factor" run-file ]
[ relative-overflow-stack { 1 2 3 } sequence= ]
must-fail-with

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

[ ] [ "parser" reload ] unit-test

[ ] [
    [ "this-better-not-exist" forget-vocab ] with-compilation-unit
] unit-test

[
    "USE: this-better-not-exist" eval
] must-fail
