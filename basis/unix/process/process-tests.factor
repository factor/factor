USING: eval alien.c-types alien.data continuations kernel locals system
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

! Match the native Haiku sys/wait.h layout without changing other platforms.
os haiku? [
    "USING: kernel tools.test unix.process ; IN: unix.process.tests
    { t t f f } [ 0 WIFEXITED 255 WIFEXITED 0xf00 WIFEXITED 0x130000 WIFEXITED ] unit-test
    { 0 7 13 255 } [ 0 WEXITSTATUS 7 WEXITSTATUS 13 WEXITSTATUS 255 WEXITSTATUS ] unit-test
    { f t f } [ 13 WIFSIGNALED 0xf00 WIFSIGNALED 0x130000 WIFSIGNALED ] unit-test
    { 0 15 } [ 13 WTERMSIG 0xf00 WTERMSIG ] unit-test
    { f t } [ 13 WIFSTOPPED 0x130000 WIFSTOPPED ] unit-test
    { 19 } [ 0x130000 WSTOPSIG ] unit-test
    { f t } [ 0 WCOREDUMP 0x10000 WCOREDUMP ] unit-test
    { f t } [ 13 WIFCONTINUED 0x20000 WIFCONTINUED ] unit-test
    { f t 255 t 255 t t } [ -1 WIFEXITED -1 WIFSIGNALED -1 WTERMSIG -1 WIFSTOPPED -1 WSTOPSIG -1 WCOREDUMP -1 WIFCONTINUED ] unit-test
    { 4 8 16 32 } [ WCONTINUED WEXITED WSTOPPED WNOWAIT ] unit-test
" eval( -- )
] when
