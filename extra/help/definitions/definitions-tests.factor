USING: math definitions help.topics help tools.test
prettyprint parser io.streams.string kernel source-files
assocs namespaces words io ;
IN: temporary

[ ] [ \ + >link see ] unit-test

[
    file-vocabs

    [ 4 ] [
        "IN: temporary USING: help.syntax ; : hello ; HELP: hello \"test\" ; ARTICLE: \"hello\" \"world\" ; ARTICLE: \"hello2\" \"world\" ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions assoc-size
    ] unit-test

    [ t ] [ "hello" articles get key? ] unit-test
    [ t ] [ "hello2" articles get key? ] unit-test
    [ t ] [
        "hello" "temporary" lookup "help" word-prop >boolean
    ] unit-test

    [ 2 ] [
        "IN: temporary USING: help.syntax ; : hello ; ARTICLE: \"hello\" \"world\" ;" <string-reader> "foo"
        parse-stream drop

        "foo" source-file source-file-definitions assoc-size
    ] unit-test

    [ t ] [ "hello" articles get key? ] unit-test
    [ f ] [ "hello2" articles get key? ] unit-test
    [ f ] [
        "hello" "temporary" lookup "help" word-prop
    ] unit-test

    [ [ ] ] [ "IN: temporary USING: help.syntax ; : xxx ; HELP: xxx ;" parse ] unit-test

    [ ] [ "xxx" "temporary" lookup help ] unit-test

    [ ] [ "xxx" "temporary" lookup >link synopsis print ] unit-test
] with-scope
