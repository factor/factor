USING: math definitions help.topics help tools.test
prettyprint parser io.streams.string kernel source-files
assocs namespaces words io sequences ;
IN: help.definitions.tests

[ ] [ \ + >link see ] unit-test

[
    [ 4 ] [
        "IN: help.definitions.tests USING: help.syntax ; : hello ; HELP: hello \"test\" ; ARTICLE: \"hello\" \"world\" ; ARTICLE: \"hello2\" \"world\" ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test

    [ t ] [ "hello" articles get key? ] unit-test
    [ t ] [ "hello2" articles get key? ] unit-test
    [ t ] [
        "hello" "help.definitions" lookup "help" word-prop >boolean
    ] unit-test

    [ 2 ] [
        "IN: help.definitions.tests USING: help.syntax ; : hello ; ARTICLE: \"hello\" \"world\" ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions first assoc-size
    ] unit-test

    [ t ] [ "hello" articles get key? ] unit-test
    [ f ] [ "hello2" articles get key? ] unit-test
    [ f ] [
        "hello" "help.definitions" lookup "help" word-prop
    ] unit-test

    [ ] [ "IN: help.definitions.tests USING: help.syntax ; : xxx ; HELP: xxx ;" eval ] unit-test

    [ ] [ "xxx" "help.definitions" lookup help ] unit-test

    [ ] [ "xxx" "help.definitions" lookup >link synopsis print ] unit-test
] with-file-vocabs
