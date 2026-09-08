USING: alien.c-types alien.data continuations kernel locals system
tools.test unix.process ;
IN: unix.process.tests

! Mutate only a private spawn attribute, not this process's scheduler.
:: scheduler-roundtrip ( -- policy priority )
    posix-spawnattr-init :> attr
    [
        attr 0 posix_spawnattr_setschedpolicy check-posix
        attr 7 int <ref>
        posix_spawnattr_setschedparam check-posix
        attr 0 int <ref> [ posix_spawnattr_getschedpolicy check-posix ] keep int deref
        attr 0 int <ref> [ posix_spawnattr_getschedparam check-posix ] keep int deref
    ] [ attr posix-spawnattr-destroy ] finally ;

! Linux's struct sched_param contains one int; other OS layouts may differ.
os linux? [
    { 0 7 } [ scheduler-roundtrip ] unit-test
    { 0x80 } [ POSIX_SPAWN_SETSID ] unit-test
] when

{ } [ posix-spawn-file-actions-init posix-spawn-file-actions-destroy ] unit-test
