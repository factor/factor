IN: io.monitors.tests
USING: io.monitors tools.test io.files system sequences
continuations namespaces concurrency.count-downs kernel io
threads calendar ;

os { winnt macosx linux } member? [
    [ "monitor-test" temp-file delete-tree ] ignore-errors

    [ ] [ "monitor-test" temp-file make-directory ] unit-test

    [ ] [ "monitor-test" temp-file t <monitor> "m" set ] unit-test

    [ ] [ 1 <count-down> "c" set ] unit-test

    [ ] [
        [
           [
               "m" get next-change drop
               dup print flush
               "test.txt" tail? not
           ] [ ] [ ] while
           "c" get count-down
        ] "Monitor test thread" spawn drop
    ] unit-test

    [ ] [ "monitor-test/test.txt" touch-file ] unit-test

    [ ] [ "c" get 30 seconds await-timeout ] unit-test
] when
