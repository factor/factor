! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger prettyprint accessors unix kernel ;
FROM: io => write print nl ;
IN: unix.debugger

M: unix-error error.
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
