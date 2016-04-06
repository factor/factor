USING: accessors calendar concurrency.count-downs
concurrency.promises continuations destructors io io.directories
io.files io.monitors io.pathnames io.timeouts kernel namespaces
sequences threads tools.test ;

[
    [
        { } [ "." t <monitor> "m" set ] unit-test

        { } [ "a1" make-directory ] unit-test
        { } [ "a2" make-directory ] unit-test
        { } [ "a1" "a2" move-file-into ] unit-test

        { t } [ "a2/a1" exists? ] unit-test

        { } [ "a2/a1/a3.txt" touch-file ] unit-test

        { t } [ "a2/a1/a3.txt" exists? ] unit-test

        { } [ "a2/a1/a4.txt" touch-file ] unit-test
        { } [ "a2/a1/a5.txt" touch-file ] unit-test
        { } [ "a2/a1/a4.txt" delete-file ] unit-test
        { } [ "a2/a1/a5.txt" "a2/a1/a4.txt" move-file ] unit-test

        { t } [ "a2/a1/a4.txt" exists? ] unit-test

        { } [ "m" get dispose ] unit-test
    ] with-monitors
] with-test-directory

[
    [
        { } [ "xyz" make-directory ] unit-test
        { } [ "." t <monitor> "m" set ] unit-test

        { } [ 1 <count-down> "b" set ] unit-test
        { } [ 1 <count-down> "c1" set ] unit-test
        { } [ 1 <count-down> "c2" set ] unit-test

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

        { } [ "b" get await ] unit-test
        { } [ "xyz/test.txt" touch-file ] unit-test
        { } [ "c1" get 1 minutes await-timeout ] unit-test
        { } [ "subdir/blah/yxy" make-directories ] unit-test
        { } [ "subdir/blah/yxy/test.txt" touch-file ] unit-test
        { } [ "c2" get 1 minutes await-timeout ] unit-test

        ! Dispose twice
        { } [ "m" get dispose ] unit-test
        { } [ "m" get dispose ] unit-test
    ] with-monitors
] with-test-directory

! Out-of-scope disposal should not fail
{ } [ [ "resource:" f <monitor> ] with-monitors dispose ] unit-test
{ } [ [ "resource:" t <monitor> ] with-monitors dispose ] unit-test

! Timeouts
[
    [
        ! Non-recursive
        { } [
            "." f <monitor> "m" set
            100 milliseconds "m" get set-timeout
            [ [ t ] [ "m" get next-change drop ] while ] must-fail
            "m" get dispose
        ] unit-test

        ! Recursive
        { } [
            "." t <monitor> "m" set
            100 milliseconds "m" get set-timeout
            [ [ t ] [ "m" get next-change drop ] while ] must-fail
            "m" get dispose
        ] unit-test
    ] with-monitors
] with-test-directory

! Disposing a monitor should throw an error in any threads
! waiting on notifications
[
    [
        { } [
            <promise> "p" set
            "." t <monitor> "m" set
            10 seconds "m" get set-timeout
        ] unit-test

        [
            [ "m" get next-change ] [ ] recover
            "p" get fulfill
        ] in-thread

        { } [
            100 milliseconds sleep
            "m" get dispose
        ] unit-test

        { t } [
            "p" get 10 seconds ?promise-timeout
            already-disposed?
        ] unit-test
    ] with-monitors
] with-test-directory
