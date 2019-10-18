USING: accessors calendar destructors io.directories io.monitors
io.pathnames io.timeouts kernel namespaces tools.test ;

! On Linux, a notification on the directory itself would report an invalid
! path name
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
] with-test-directory
