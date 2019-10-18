USING: arrays math parser tools.test kernel generic words
io.streams.string namespaces classes effects source-files
assocs sequences strings io.files definitions continuations
sorting tuples ;
IN: temporary

[
    file-vocabs

    [ 1 CHAR: a ]
    [ 0 "abcd" next-char ] unit-test

    [ 6 CHAR: \s ]
    [ 1 "\\u0020hello" next-escape ] unit-test

    [ 2 CHAR: \n ]
    [ 1 "\\nhello" next-escape ] unit-test

    [ 6 CHAR: \s ]
    [ 0 "\\u0020hello" next-char ] unit-test

    [ [ 1 [ 2 [ 3 ] 4 ] 5 ] ]
    [ "1\n[\n2\n[\n3\n]\n4\n]\n5" parse ]
    unit-test

    [ [ t t f f ] ]
    [ "t t f f" parse ]
    unit-test

    [ [ "hello world" ] ]
    [ "\"hello world\"" parse ]
    unit-test

    [ [ "\n\r\t\\" ] ]
    [ "\"\\n\\r\\t\\\\\"" parse ]
    unit-test

    [ "hello world" ]
    [
        "IN: temporary : hello \"hello world\" ;"
        parse call "USE: scratchpad hello" eval
    ] unit-test

    [ ]
    [ "! This is a comment, people." parse call ]
    unit-test

    ! Test escapes

    [ [ " " ] ]
    [ "\"\\u0020\"" parse ]
    unit-test

    [ [ "'" ] ]
    [ "\"\\u0027\"" parse ]
    unit-test

    [ "\\u123" parse ] unit-test-fails

    ! Test EOL comments in multiline strings.
    [ [ "Hello" ] ] [ "#! This calls until-eol.\n\"Hello\"" parse ] unit-test

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

    [ [ ] ] [ "IN: temporary USE: math : effect-parsing-test ( a b -- d ) - ;" parse ] unit-test

    [ t ] [
        "effect-parsing-test" "temporary" lookup
        \ effect-parsing-test eq?
    ] unit-test

    [ T{ effect f { "a" "b" } { "d" } f } ]
    [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    [ [ ] ] [ "IN: temporary : effect-parsing-test ;" parse ] unit-test

    [ f ] [ \ effect-parsing-test "declared-effect" word-prop ] unit-test

    ! Funny bug
    [ 2 ] [ "IN: temporary : \0. 2 ; \0." eval ] unit-test

    [ "IN: temporary : missing-- ( a b ) ;" eval ] unit-test-fails

    ! These should throw errors
    [ "HEX: zzz" parse ] unit-test-fails
    [ "OCT: 999" parse ] unit-test-fails
    [ "BIN: --0" parse ] unit-test-fails

    [ f ] [
        "IN: temporary : foo ; TUPLE: foo ;" parse drop
        "foo" "temporary" lookup symbol?
    ] unit-test

    ! Another funny bug
    [ t ] [
        [
            "scratchpad" in set
            { "scratchpad" "arrays" } set-use
            [
                ! This shouldn't modify in/use in the outer scope!
                file-vocabs
            ] with-scope

            use get { "scratchpad" "arrays" } set-use use get =
        ] with-scope
    ] unit-test
    DEFER: foo

    "IN: temporary USING: math prettyprint ; : foo 2 2 + . ; parsing" eval

    [ [ ] ] [ "USE: temporary foo" parse ] unit-test

    "IN: temporary USING: math prettyprint ; : foo 2 2 + . ;" eval

    [ t ] [
        "USE: temporary foo" parse
        first "foo" "temporary" lookup eq?
    ] unit-test

    ! Test smudging

    [ 1 ] [
        "IN: temporary : smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions assoc-size
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

        "foo" source-file source-file-definitions assoc-size
    ] unit-test

    [ 1 ] [
        "IN: temporary USING: arrays ; M: array smudge-me ;" <string-reader> "bar"
        parse-stream drop

        "bar" source-file source-file-definitions assoc-size
    ] unit-test

    [ 2 ] [
        "IN: temporary USING: math strings ; GENERIC: smudge-me M: integer smudge-me ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions assoc-size
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

    [ t ] [
        [
            "IN: temporary : x ; : y 3 throw ; parsing y"
            <string-reader> "a" parse-stream
        ] catch parse-error?
    ] unit-test

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
        "IN: temporary GENERIC: killer?"
        <string-reader> "removing-the-predicate" parse-stream drop
    ] unit-test
    
    [ t ] [
        "killer?" "temporary" lookup >boolean
    ] unit-test

    [ t ] [
        [
            "IN: temporary TUPLE: another-pred-test ; GENERIC: another-pred-test?"
            <string-reader> "removing-the-predicate" parse-stream
        ] catch [ redefine-error? ] is?
    ] unit-test
] with-scope

[
    : FILE file get parsed ; parsing

    FILE file set

    : ~a ;
    : ~b ~a ;
    : ~c ;
    : ~d ;

    H{ { ~a ~a } { ~c ~c } { ~d ~d } } old-definitions set
    
    H{ { ~d ~d } } new-definitions set
    
    [ V{ ~b } { ~a } { ~a ~c } ] [
        smudged-usage
        natural-sort
    ] unit-test
] with-scope
