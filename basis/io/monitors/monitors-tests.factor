IN: io.monitors.tests
USING: io.monitors tools.test io.files system sequences
continuations namespaces concurrency.count-downs kernel io
threads calendar prettyprint destructors io.timeouts
io.files.temp io.directories io.directories.hierarchy
io.pathnames accessors ;

os { winnt linux macosx } member? [
    [
        [ "monitor-test" temp-file delete-tree ] ignore-errors

        [ ] [ "monitor-test" temp-file make-directory ] unit-test

        [ ] [ "monitor-test" temp-file t <monitor> "m" set ] unit-test

        [ ] [ "monitor-test/a1" temp-file make-directory ] unit-test

        [ ] [ "monitor-test/a2" temp-file make-directory ] unit-test

        [ ] [ "monitor-test/a1" temp-file "monitor-test/a2" temp-file move-file-into ] unit-test

        [ t ] [ "monitor-test/a2/a1" temp-file exists? ] unit-test

        [ ] [ "monitor-test/a2/a1/a3.txt" temp-file touch-file ] unit-test

        [ t ] [ "monitor-test/a2/a1/a3.txt" temp-file exists? ] unit-test

        [ ] [ "monitor-test/a2/a1/a4.txt" temp-file touch-file ] unit-test
        [ ] [ "monitor-test/a2/a1/a5.txt" temp-file touch-file ] unit-test
        [ ] [ "monitor-test/a2/a1/a4.txt" temp-file delete-file ] unit-test
        [ ] [ "monitor-test/a2/a1/a5.txt" temp-file "monitor-test/a2/a1/a4.txt" temp-file move-file ] unit-test

        [ t ] [ "monitor-test/a2/a1/a4.txt" temp-file exists? ] unit-test

        [ ] [ "m" get dispose ] unit-test
    ] with-monitors

    [
        [ "monitor-test" temp-file delete-tree ] ignore-errors
        
        [ ] [ "monitor-test/xyz" temp-file make-directories ] unit-test
        
        [ ] [ "monitor-test" temp-file t <monitor> "m" set ] unit-test
        
        [ ] [ 1 <count-down> "b" set ] unit-test
        
        [ ] [ 1 <count-down> "c1" set ] unit-test
        
        [ ] [ 1 <count-down> "c2" set ] unit-test
        
        [ ] [
            [
                "b" get count-down

                [
                    "m" get next-change path>>
                    dup print flush
                    dup parent-directory
                    [ trim-tail-separators "xyz" tail? ] either? not
                ] loop

                "c1" get count-down
                
                [
                    "m" get next-change path>>
                    dup print flush
                    dup parent-directory
                    [ trim-tail-separators "yxy" tail? ] either? not
                ] loop

                "c2" get count-down
            ] "Monitor test thread" spawn drop
        ] unit-test
        
        [ ] [ "b" get await ] unit-test
        
        [ ] [ "monitor-test/xyz/test.txt" temp-file touch-file ] unit-test

        [ ] [ "c1" get 1 minutes await-timeout ] unit-test
        
        [ ] [ "monitor-test/subdir/blah/yxy" temp-file make-directories ] unit-test

        [ ] [ "monitor-test/subdir/blah/yxy/test.txt" temp-file touch-file ] unit-test

        [ ] [ "c2" get 1 minutes await-timeout ] unit-test

        ! Dispose twice
        [ ] [ "m" get dispose ] unit-test

        [ ] [ "m" get dispose ] unit-test
    ] with-monitors

    ! Out-of-scope disposal should not fail
    [ ] [ [ "" resource-path f <monitor> ] with-monitors dispose ] unit-test
    [ ] [ [ "" resource-path t <monitor> ] with-monitors dispose ] unit-test
    
    ! Timeouts
    [
        [ ] [ "monitor-timeout-test" temp-file make-directories ] unit-test

        ! Non-recursive
        [ ] [ "monitor-timeout-test" temp-file f <monitor> "m" set ] unit-test
        [ ] [ 3 seconds "m" get set-timeout ] unit-test
        [ [ t ] [ "m" get next-change drop ] while ] must-fail
        [ ] [ "m" get dispose ] unit-test

        ! Recursive
        [ ] [ "monitor-timeout-test" temp-file t <monitor> "m" set ] unit-test
        [ ] [ 3 seconds "m" get set-timeout ] unit-test
        [ [ t ] [ "m" get next-change drop ] while ] must-fail
        [ ] [ "m" get dispose ] unit-test
    ] with-monitors
] when
