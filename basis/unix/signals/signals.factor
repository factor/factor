! Copyright (C) 2011 Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs io kernel math namespaces sequences
system threads ;
IN: unix.signals

CONSTANT: signal-names
{
    "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
    "SIGEMT" "SIGFPE" "SIGKILL" "SIGBUS" "SIGSEGV" "SIGSYS"
    "SIGPIPE" "SIGALRM" "SIGTERM" "SIGURG" "SIGSTOP" "SIGTSIP"
    "SIGCONT" "SIGCHLD" "SIGTTIN" "SIGTTOU" "SIGIO" "SIGXCPU"
    "SIGXFSZ" "SIGVTALRM" "SIGPROF" "SIGWINCH" "SIGINFO"
    "SIGUSR1" "SIGUSR2"
}

TUPLE: signal n ;

GENERIC: signal-name ( obj -- str/f )

M: signal signal-name n>> signal-name ;

M: integer signal-name ( n -- str/f ) 1 - signal-names ?nth ;

: signal-name. ( n -- )
    signal-name [ " (" ")" surround write ] when* ;

SYMBOL: dispatch-signal-hook

dispatch-signal-hook [ [ drop ] ] initialize

<PRIVATE

SYMBOL: signal-handlers

signal-handlers [ H{ } ] initialize

: dispatch-signal ( sig -- )
    signal-handlers get-global at [ in-thread ] each ;

PRIVATE>

: add-signal-handler ( handler: ( -- ) sig -- )
    signal-handlers get-global push-at ;

: remove-signal-handler ( handler sig -- )
    signal-handlers get-global at [ remove! drop ] [ drop ] if* ;

[ dispatch-signal ] dispatch-signal-hook set-global
