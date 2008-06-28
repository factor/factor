IN: io.unix.linux.monitors.tests
USING: io.monitors tools.test io.files system sequences
continuations namespaces concurrency.count-downs kernel io
threads calendar prettyprint destructors io.timeouts ;

! On Linux, a notification on the directory itself would report an invalid
! path name
[
    [ ] [ "monitor-test-self" temp-file make-directories ] unit-test
    
    ! Non-recursive
    [ ] [ "monitor-test-self" temp-file f <monitor> "m" set ] unit-test

    [ ] [ "monitor-test-self" temp-file touch-file ] unit-test

    [ t ] [
        "m" get next-change drop
        [ "." = ] [ "monitor-test-self" temp-file = ] bi or
    ] unit-test

    [ ] [ "m" get dispose ] unit-test
    
    ! Recursive
    [ ] [ "monitor-test-self" temp-file t <monitor> "m" set ] unit-test

    [ ] [ "monitor-test-self" temp-file touch-file ] unit-test

    [ t ] [
        "m" get next-change drop
        [ "" = ] [ "monitor-test-self" temp-file = ] bi or
    ] unit-test

    [ ] [ "m" get dispose ] unit-test
] with-monitors
