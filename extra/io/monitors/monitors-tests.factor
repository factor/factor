IN: io.monitors.tests
USING: io.monitors tools.test io.files system sequences
continuations namespaces concurrency.count-downs kernel io
threads calendar prettyprint ;

os { winnt macosx linux } member? [
    [ "monitor-test" temp-file delete-tree ] ignore-errors

    [ ] [ "monitor-test/xyz" temp-file make-directories ] unit-test

    [ ] [ "monitor-test" temp-file t <monitor> "m" set ] unit-test

    [ ] [ 1 <count-down> "b" set ] unit-test

    [ ] [ 1 <count-down> "c" set ] unit-test

    [ ] [
        [
            "b" get count-down
           [
               "m" get next-change drop
               dup print flush right-trim-separators
               "xyz" tail? not
           ] [ ] [ ] while
           "c" get count-down
        ] "Monitor test thread" spawn drop
    ] unit-test

    [ ] [ "b" get await ] unit-test

    [ ] [ "monitor-test/xyz/test.txt" temp-file touch-file ] unit-test

    [ ] [ "c" get 30 seconds await-timeout ] unit-test

    [ ] [ "m" get dispose ] unit-test

    [ "m" get dispose ] must-fail
] when
