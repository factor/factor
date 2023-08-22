! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors debugger io kernel libc prettyprint unix ;
IN: unix.debugger

M: libc-error error.
    "Unix system call failed:" print
    nl
    dup message>> write " (" write errno>> pprint ")" print ;

M: unix-system-call-error error.
    "Unix system call “" write dup word>> pprint "” failed:" print
    nl
    dup message>> write " (" write dup errno>> pprint ")" print
    nl
    "It was called with the following arguments:" print
    nl
    args>> stack. ;
