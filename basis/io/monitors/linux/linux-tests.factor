IN: io.monitors.linux.tests
USING: io.monitors tools.test io.files io.files.temp
io.directories system sequences continuations namespaces
concurrency.count-downs kernel io threads calendar prettyprint
destructors io.timeouts accessors ;

! On Linux, a notification on the directory itself would report an invalid
! path name
[
    [ ] [ "monitor-test-self" temp-file make-directories ] unit-test

    ! Non-recursive
    [ ] [ "monitor-test-self" temp-file f <monitor> "m" set ] unit-test
    [ ] [ 3 seconds "m" get set-timeout ] unit-test

    [ ] [ "monitor-test-self" temp-file touch-file ] unit-test

    [ t ] [
        "m" get next-change path>>
        [ "" = ] [ "monitor-test-self" temp-file = ] bi or
    ] unit-test

    [ ] [ "m" get dispose ] unit-test

    ! Recursive
    [ ] [ "monitor-test-self" temp-file t <monitor> "m" set ] unit-test
    [ ] [ 3 seconds "m" get set-timeout ] unit-test

    [ ] [ "monitor-test-self" temp-file touch-file ] unit-test

    [ t ] [
        "m" get next-change path>>
        [ "" = ] [ "monitor-test-self" temp-file = ] bi or
    ] unit-test

    [ ] [ "m" get dispose ] unit-test
] with-monitors
