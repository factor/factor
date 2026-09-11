! Copyright (C) 2011 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs io kernel literals math namespaces sequences
system threads ;
IN: unix.signals

CONSTANT: signal-names $[
    os linux? [
        {
            "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
            "SIGBUS" "SIGFPE" "SIGKILL" "SIGUSR1" "SIGSEGV" "SIGUSR2"
            "SIGPIPE" "SIGALRM" "SIGTERM" "SIGSTKFLT" "SIGCHLD"
            "SIGCONT" "SIGSTOP" "SIGTSTP" "SIGTTIN" "SIGTTOU"
            "SIGURG" "SIGXCPU" "SIGXFSZ" "SIGVTALRM" "SIGPROF"
            "SIGWINCH" "SIGIO" "SIGPWR" "SIGSYS"
        }
    ] [
        {
            "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
            "SIGEMT" "SIGFPE" "SIGKILL" "SIGBUS" "SIGSEGV" "SIGSYS"
            "SIGPIPE" "SIGALRM" "SIGTERM" "SIGURG" "SIGSTOP" "SIGTSTP"
            "SIGCONT" "SIGCHLD" "SIGTTIN" "SIGTTOU" "SIGIO" "SIGXCPU"
            "SIGXFSZ" "SIGVTALRM" "SIGPROF" "SIGWINCH" "SIGINFO"
            "SIGUSR1" "SIGUSR2"
        }
    ] if
]

TUPLE: signal n ;

GENERIC: signal-name ( obj -- str/f )

M: signal signal-name n>> signal-name ;

M: integer signal-name 1 - signal-names ?nth ;

: signal-name. ( n -- )
    signal-name [ " (" ")" surround write ] when* ;

<PRIVATE

SYMBOL: signal-handlers

signal-handlers [ H{ } ] initialize

: dispatch-signal ( sig -- )
    signal-handlers get-global at [ in-thread ] each ;

PRIVATE>

: add-signal-handler ( handler: ( -- ) sig -- )
    signal-handlers get-global push-at ;

: remove-signal-handler ( handler sig -- )
    signal-handlers get-global at [ remove-eq! ] when* drop ;

SYMBOL: dispatch-signal-hook

[ dispatch-signal ] dispatch-signal-hook set-global
