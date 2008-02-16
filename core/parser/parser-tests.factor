USING: arrays math parser tools.test kernel generic words
io.streams.string namespaces classes effects source-files
assocs sequences strings io.files definitions continuations
sorting tuples compiler.units ;
IN: temporary

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
        "IN: temporary : hello \"hello world\" ;"
        eval "USE: temporary hello" eval
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
        "effect-parsing-test" "temporary" lookup
        \ effect-parsing-test eq?
    ] unit-test

    [ T{ effect f { "a" "b" } { "c" } f } ]
    [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    : baz ( a b -- * ) 2array throw ;

    [ t ]
    [ \ baz "declared-effect" word-prop effect-terminated? ]
    unit-test

    [ ] [ "IN: temporary USE: math : effect-parsing-test ( a b -- d ) - ;" eval ] unit-test

    [ t ] [
        "effect-parsing-test" "temporary" lookup
        \ effect-parsing-test eq?
    ] unit-test

    [ T{ effect f { "a" "b" } { "d" } f } ]
    [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    [ ] [ "IN: temporary : effect-parsing-test ;" eval ] unit-test

    [ f ] [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    ! Funny bug
    [ 2 ] [ "IN: temporary : \0. 2 ; \0." eval ] unit-test

    [ "IN: temporary : missing-- ( a b ) ;" eval ] must-fail

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

    "IN: temporary USING: math prettyprint ; : foo 2 2 + . ; parsing" eval

    [ ] [ "USE: temporary foo" eval ] unit-test

    "IN: temporary USING: math prettyprint ; : foo 2 2 + . ;" eval

    [ t ] [
        "USE: temporary \\ foo" eval
        "foo" "temporary" lookup eq?
    ] unit-test

    ! Test smudging

    [ 1 ] [
        "IN: temporary : smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test

    [ t ] [ "smudge-me" "temporary" lookup >boolean ] unit-test

    [ ] [
        "IN: temporary : smudge-me-more ;" <string-reader> "foo"
        parse-stream drop
    ] unit-test

    [ t ] [ "smudge-me-more" "temporary" lookup >boolean ] unit-test
    [ f ] [ "smudge-me" "temporary" lookup >boolean ] unit-test

    [ 3 ] [
        "IN: temporary USING: math strings ; GENERIC: smudge-me M: integer smudge-me ; M: string smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test

    [ 1 ] [
        "IN: temporary USING: arrays ; M: array smudge-me ;" <string-reader> "bar"
        parse-stream drop

        "bar" source-file source-file-definitions first assoc-size
    ] unit-test

    [ 2 ] [
        "IN: temporary USING: math strings ; GENERIC: smudge-me M: integer smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test
    
    [ t ] [
        array "smudge-me" "temporary" lookup order memq?
    ] unit-test
    
    [ t ] [
        integer "smudge-me" "temporary" lookup order memq?
    ] unit-test
    
    [ f ] [
        string "smudge-me" "temporary" lookup order memq?
    ] unit-test

    [ ] [
        "IN: temporary USE: math 2 2 +" <string-reader> "a"
        parse-stream drop
    ] unit-test
    
    [ t ] [
        "a" <pathname> \ + usage member?
    ] unit-test

    [ ] [
        "IN: temporary USE: math 2 2 -" <string-reader> "a"
        parse-stream drop
    ] unit-test
    
    [ f ] [
        "a" <pathname> \ + usage member?
    ] unit-test
    
    [ ] [
        "a" source-files get delete-at
        2 [
            "IN: temporary DEFER: x : y x ; : x y ;"
            <string-reader> "a" parse-stream drop
        ] times
    ] unit-test
    
    "a" source-files get delete-at

    [
        "IN: temporary : x ; : y 3 throw ; this is an error"
        <string-reader> "a" parse-stream
    ] [ parse-error? ] must-fail-with

    [ t ] [
        "y" "temporary" lookup >boolean
    ] unit-test

    [ f ] [
        "IN: temporary : x ;"
        <string-reader> "a" parse-stream drop
        
        "y" "temporary" lookup
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
        "IN: temporary : <bogus-error> ; : bogus <bogus-error> ;"
        <string-reader> "bogus-error" parse-stream drop
    ] unit-test

    [ ] [
        "IN: temporary TUPLE: bogus-error ; C: <bogus-error> bogus-error : bogus <bogus-error> ;"
        <string-reader> "bogus-error" parse-stream drop
    ] unit-test

    ! Problems with class predicates -vs- ordinary words
    [ ] [
        "IN: temporary TUPLE: killer ;"
        <string-reader> "removing-the-predicate" parse-stream drop
    ] unit-test

    [ ] [
        "IN: temporary GENERIC: killer? ( a -- b )"
        <string-reader> "removing-the-predicate" parse-stream drop
    ] unit-test
    
    [ t ] [
        "killer?" "temporary" lookup >boolean
    ] unit-test

    [
        "IN: temporary TUPLE: another-pred-test ; GENERIC: another-pred-test?"
        <string-reader> "removing-the-predicate" parse-stream
    ] [ [ redefine-error? ] is? ] must-fail-with

    [
        "IN: temporary TUPLE: class-redef-test ; TUPLE: class-redef-test ;"
        <string-reader> "redefining-a-class-1" parse-stream
    ] [ [ redefine-error? ] is? ] must-fail-with

    [ ] [
        "IN: temporary TUPLE: class-redef-test ; SYMBOL: class-redef-test"
        <string-reader> "redefining-a-class-2" parse-stream drop
    ] unit-test

    [
        "IN: temporary TUPLE: class-redef-test ; SYMBOL: class-redef-test : class-redef-test ;"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ [ redefine-error? ] is? ] must-fail-with

    [ ] [
        "IN: temporary TUPLE: class-fwd-test ;"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] unit-test

    [
        "IN: temporary \\ class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ [ no-word? ] is? ] must-fail-with

    [ ] [
        "IN: temporary TUPLE: class-fwd-test ; SYMBOL: class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] unit-test

    [
        "IN: temporary \\ class-fwd-test"
        <string-reader> "redefining-a-class-3" parse-stream drop
    ] [ [ no-word? ] is? ] must-fail-with

    [
        "IN: temporary : foo ; TUPLE: foo ;"
        <string-reader> "redefining-a-class-4" parse-stream drop
    ] [ [ redefine-error? ] is? ] must-fail-with

    [ ] [
        "IN: temporary : foo ( x y -- z ) 1 2 ; : bar ( a -- b ) ;" eval
    ] unit-test

    [
        "IN: temporary : foo ( x y -- z) 1 2 ; : bar ( a -- b ) ;" eval
    ] must-fail
] with-file-vocabs

[
    << file get parsed >> file set

    : ~a ;
    : ~b ~a ;
    : ~c ;
    : ~d ;

    { H{ { ~a ~a } { ~c ~c } { ~d ~d } } H{ } } old-definitions set
    
    { H{ { ~d ~d } } H{ } } new-definitions set
    
    [ V{ ~b } { ~a } { ~a ~c } ] [
        smudged-usage
        natural-sort
    ] unit-test
] with-scope

[ ] [
    "IN: temporary USE: kernel PREDICATE: object foo ( x -- y ) ;" eval
] unit-test

[ t ] [
    "foo?" "temporary" lookup word eq?
] unit-test
