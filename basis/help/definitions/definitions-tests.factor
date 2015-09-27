USING: math definitions help.topics help tools.test sets
prettyprint parser io.streams.string kernel source-files
assocs namespaces words io sequences eval accessors see ;
IN: help.definitions.tests

{ } [ \ + >link see ] unit-test

[
    [ 4 ] [
        "IN: help.definitions.tests USING: help.syntax ; : hello ( -- ) ; HELP: hello \"test\" ; ARTICLE: \"hello\" \"world\" ; ARTICLE: \"hello2\" \"world\" ;" <string-reader> "foo"
        parse-stream drop

        "foo" path>source-file definitions>> first cardinality
    ] unit-test

    [ t ] [ "hello" articles get key? ] unit-test
    [ t ] [ "hello2" articles get key? ] unit-test
    [ t ] [
        "hello" "help.definitions.tests" lookup-word "help" word-prop >boolean
    ] unit-test

    [ 2 ] [
        "IN: help.definitions.tests USING: help.syntax ; : hello ( -- ) ; ARTICLE: \"hello\" \"world\" ;" <string-reader> "foo"
        parse-stream drop

        "foo" path>source-file definitions>> first cardinality
    ] unit-test

    [ t ] [ "hello" articles get key? ] unit-test
    [ f ] [ "hello2" articles get key? ] unit-test
    [ f ] [
        "hello" "help.definitions.tests" lookup-word "help" word-prop
    ] unit-test

    [ ] [ "IN: help.definitions.tests USING: help.syntax ; : xxx ( -- ) ; HELP: xxx ;" eval( -- ) ] unit-test

    [ ] [ "xxx" "help.definitions.tests" lookup-word print-topic ] unit-test

    [ ] [ "xxx" "help.definitions.tests" lookup-word >link synopsis print ] unit-test
] with-file-vocabs
