IN: io.monitors.tests
USING: io.monitors tools.test io.files system sequences
continuations namespaces concurrency.count-downs kernel io
threads calendar prettyprint ;

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
                    "m" get next-change drop
                    dup print flush
                    dup parent-directory
                    [ right-trim-separators "xyz" tail? ] either? not
                ] [ ] [ ] while

                "c1" get count-down
                
                [
                    "m" get next-change drop
                    dup print flush
                    dup parent-directory
                    [ right-trim-separators "yxy" tail? ] either? not
                ] [ ] [ ] while

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
] when
