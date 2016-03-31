IN: io.monitors.linux.tests
USING: io.monitors tools.test io.files io.files.temp
io.files.unique io.directories io.pathnames system sequences
continuations namespaces concurrency.count-downs kernel io
threads calendar prettyprint destructors io.timeouts accessors ;

! On Linux, a notification on the directory itself would report an invalid
! path name
[
    [
        [
            ! Non-recursive
            { } [
                "." f <monitor> "m" set
                3 seconds "m" get set-timeout
                "." touch-file
            ] unit-test

            { t } [
                "m" get next-change path>>
                [ "" = ] [ "." absolute-path = ] bi or
            ] unit-test

            { } [ "m" get dispose ] unit-test

            ! Recursive
            { } [
                "." t <monitor> "m" set
                3 seconds "m" get set-timeout
                "." touch-file
            ] unit-test

            { t } [
                "m" get next-change path>>
                [ "" = ] [ "." absolute-path = ] bi or
            ] unit-test

            { } [ "m" get dispose ] unit-test
        ] with-monitors
    ] cleanup-unique-directory
] with-temp-directory
