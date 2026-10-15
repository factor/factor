! Copyright (C) 2011 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs io kernel literals math namespaces sequences
system threads ;
IN: unix.signals

CONSTANT: signal-names $[
    os haiku? [
        { "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGCHLD" "SIGABRT" "SIGPIPE" "SIGFPE" "SIGKILL" "SIGSTOP" "SIGSEGV" "SIGCONT" "SIGTSTP" "SIGALRM" "SIGTERM" "SIGTTIN" "SIGTTOU" "SIGUSR1" "SIGUSR2" "SIGWINCH" "SIGKILLTHR" "SIGTRAP" "SIGPOLL" "SIGPROF" "SIGSYS" "SIGURG" "SIGVTALRM" "SIGXCPU" "SIGXFSZ" "SIGBUS" "SIGRESERVED1" "SIGRESERVED2" }
    ] [
    os linux? cpu alpha.64? not and [
        cpu mips? [
            {
                "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
                "SIGEMT" "SIGFPE" "SIGKILL" "SIGBUS" "SIGSEGV" "SIGSYS"
                "SIGPIPE" "SIGALRM" "SIGTERM" "SIGUSR1" "SIGUSR2" "SIGCHLD"
                "SIGPWR" "SIGWINCH" "SIGURG" "SIGIO" "SIGSTOP" "SIGTSTP"
                "SIGCONT" "SIGTTIN" "SIGTTOU" "SIGVTALRM" "SIGPROF"
                "SIGXCPU" "SIGXFSZ"
            }
        ] [
            {
                "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
                "SIGBUS" "SIGFPE" "SIGKILL" "SIGUSR1" "SIGSEGV" "SIGUSR2"
                "SIGPIPE" "SIGALRM" "SIGTERM" "SIGSTKFLT" "SIGCHLD"
                "SIGCONT" "SIGSTOP" "SIGTSTP" "SIGTTIN" "SIGTTOU"
                "SIGURG" "SIGXCPU" "SIGXFSZ" "SIGVTALRM" "SIGPROF"
                "SIGWINCH" "SIGIO" "SIGPWR" "SIGSYS"
            }
        ] if
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
