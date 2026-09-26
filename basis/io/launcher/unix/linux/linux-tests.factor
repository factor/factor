USING: accessors alien.libraries calendar continuations io.backend io.backend.unix
io.launcher io.launcher.private io.launcher.unix.linux kernel libc
locals math math.bitwise namespaces system tools.annotations tools.test
unix unix.ffi ;
IN: io.launcher.unix.linux.tests

! Old kernels/libcs and resource failures must retain polling.
{ f f } [
    [
        \ pidfd_open [ drop [ 2drop "pidfd unavailable" throw ] ] annotate
        linux io-backend [
            <process> 123 >>handle
            dup ensure-process-monitor swap exit-monitor>>
        ] with-variable
    ] [ \ pidfd_open reset ] finally
] unit-test

: pidfds-available? ( -- ? )
    "pidfd_open" "libc" dlsym? [
        [ getpid 0 pidfd_open dup io-error close-file t ] [ drop f ] recover
    ] [ f ] if ;

: pidfd-cloexec? ( process -- ? )
    exit-monitor>> fd>> F_GETFD 0 [ fcntl ] unix-system-call
    FD_CLOEXEC bitand 0 > ;

pidfds-available? [
    ! Readiness must wake the waiter, and reaping must release the pidfd.
    { t t f } [ [let
        <process> { "sleep" "30" } >>command 5 seconds >>timeout
        run-detached :> process
        [
            process ensure-process-monitor
            process pidfd-cloexec?
        ] [
            process (kill-process)
            process wait-for-process drop
        ] finally
        process exit-monitor>>
    ] ] unit-test
] when
