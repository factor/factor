! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger io kernel math prettyprint sequences system ;
IN: debugger.unix

CONSTANT: signal-names
{
    "SIGHUP" "SIGINT" "SIGQUIT" "SIGILL" "SIGTRAP" "SIGABRT"
    "SIGEMT" "SIGFPE" "SIGKILL" "SIGBUS" "SIGSEGV" "SIGSYS"
    "SIGPIPE" "SIGALRM" "SIGTERM" "SIGURG" "SIGSTOP" "SIGTSIP"
    "SIGCONT" "SIGCHLD" "SIGTTIN" "SIGTTOU" "SIGIO" "SIGXCPU"
    "SIGXFSZ" "SIGVTALRM" "SIGPROF" "SIGWINCH" "SIGINFO"
    "SIGUSR1" "SIGUSR2"
}

: signal-name ( n -- str/f ) 1- signal-names ?nth ;

: signal-name. ( n -- )
    signal-name [ " (" ")" surround write ] when* ;

M: unix signal-error. ( obj -- )
    "Unix signal #" write
    third [ pprint ] [ signal-name. ] bi nl ;
