USING: alien.c-types byte-arrays continuations io kernel libc locals
unix.process unix.types ;
IN: mips.signal-mask-probe

:: signal-mask-roundtrip ( -- )
    sigset_t heap-size <byte-array> :> mask
    sigset_t heap-size <byte-array> :> old-mask
    sigset_t heap-size <byte-array> :> current-mask
    mask sigemptyset 0 assert=
    mask SIGUSR1 sigaddset 0 assert=
    SIG_BLOCK mask old-mask pthread_sigmask 0 assert=
    [
        SIG_SETMASK f current-mask pthread_sigmask 0 assert=
        1 current-mask SIGUSR1 sigismember assert=
    ] [ SIG_SETMASK old-mask f pthread_sigmask 0 assert= ] finally
    SIG_SETMASK f current-mask pthread_sigmask 0 assert=
    old-mask SIGUSR1 sigismember current-mask SIGUSR1 sigismember assert= ;

signal-mask-roundtrip
"MIPS pthread signal-mask roundtrip PASS" print
