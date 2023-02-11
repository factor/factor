USING: accessors calendar concurrency.count-downs
concurrency.promises continuations destructors io io.directories
io.files io.monitors io.pathnames io.timeouts kernel namespaces
sequences threads tools.test ;

{ t t t } [
    [
        [
            "." t <monitor> "m" set

            "a1" make-directory
            "a2" make-directory
            "a1" "a2" move-file-into

            "a2/a1" file-exists?

            "a2/a1/a3.txt" touch-file

            "a2/a1/a3.txt" file-exists?

            "a2/a1/a4.txt" touch-file
            "a2/a1/a5.txt" touch-file
            "a2/a1/a4.txt" delete-file
            "a2/a1/a5.txt" "a2/a1/a4.txt" move-file

            "a2/a1/a4.txt" file-exists?

            "m" get dispose
        ] with-monitors
    ] with-test-directory
] unit-test

{ } [
    [
        [
            "xyz" make-directory
            "." t <monitor> "m" set

            1 <count-down> "b" set
            1 <count-down> "c1" set
            1 <count-down> "c2" set
            1 <count-down> "c3" set

            [
                "b" get count-down

                [
                    "m" get next-change path>>
                    dup print flush
                    [ parent-directory ] keep
                    [ trim-tail-separators ] bi@
                    [ "xyz" tail? ] [ "test.txt" tail? ] bi* and not
                ] loop

                "c1" get count-down
                [
                    "m" get next-change path>>
                    dup print flush
                    [ parent-directory ] keep
                    [ trim-tail-separators ] bi@
                    [ "blah" tail? ] [ "yxy" tail? ] bi* and not
                ] loop

                "c2" get count-down
                [
                    "m" get next-change path>>
                    dup print flush
                    [ parent-directory ] keep
                    [ trim-tail-separators ] bi@
                    [ "yxy" tail? ] [ "test.txt" tail? ] bi* and not
                ] loop

                "c3" get count-down
            ] "Monitor test thread" spawn drop

            "b" get await

            "xyz/test.txt" touch-file
            "c1" get 1 minutes await-timeout

            "subdir/blah/yxy" make-directories
            "c2" get 1 minutes await-timeout

            "subdir/blah/yxy/test.txt" touch-file
            "c3" get 1 minutes await-timeout

            ! Dispose twice
            "m" get dispose
            "m" get dispose
        ] with-monitors
    ] with-test-directory
] unit-test

! Out-of-scope disposal should not fail
{ } [ [ "resource:" f <monitor> ] with-monitors dispose ] unit-test
{ } [ [ "resource:" t <monitor> ] with-monitors dispose ] unit-test

! Timeouts
[
    [
        ! Non-recursive
        { } [
            "." f <monitor> "m" set
            250 milliseconds "m" get set-timeout
            [ [ t ] [ "m" get next-change drop ] while ] must-fail
            "m" get dispose
        ] unit-test

        ! Recursive
        { } [
            "." t <monitor> "m" set
            250 milliseconds "m" get set-timeout
            [ [ t ] [ "m" get next-change drop ] while ] must-fail
            "m" get dispose
        ] unit-test
    ] with-monitors
] with-test-directory

! Disposing a monitor should throw an error in any threads
! waiting on notifications
{ t } [
    [
        [
            <promise> "p" set
            "." t <monitor> "m" set
            10 seconds "m" get set-timeout

            [
                250 milliseconds sleep ! let the dispose run, then pump
                [ "m" get next-change ] [ ] recover ! pump event
                "p" get fulfill
            ] in-thread

            "m" get dispose

            "p" get 10 seconds ?promise-timeout
            already-disposed?
        ] with-monitors
    ] with-test-directory
] unit-test
