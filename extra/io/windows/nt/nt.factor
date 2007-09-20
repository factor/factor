! Copyright (C) 2004, 2007 Mackenzie Straight, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types assocs byte-arrays combinators
io.backend io.files io.nonblocking io.windows
kernel libc math namespaces qualified sequences
splitting strings threads windows windows.errors windows.winsock
windows.kernel32 ;
QUALIFIED: windows.winsock
IN: io.windows.nt

: unicode-prefix ( -- seq )
    "\\\\?\\" ; inline
 
M: windows-nt-io normalize-pathname ( string -- string )
    dup string? [ "pathname must be a string" throw ] unless
    "/" split "\\" join
    {
        ! empty
        { [ dup empty? ] [ "empty path" throw ] }
        ! .\\foo
        { [ dup ".\\" head? ] [
            >r unicode-prefix cwd r> 1 tail 3append
        ] }
        ! c:\\
        { [ dup 1 tail ":" head? ] [ >r unicode-prefix r> append ] }
        ! \\\\?\\c:\\foo
        { [ dup unicode-prefix head? ] [ ] }
        ! foo.txt ..\\foo.txt
        { [ t ] [
            [
                unicode-prefix % cwd %
                dup first CHAR: \\ = [ CHAR: \\ , ] unless %
            ] "" make
        ] }
    } cond [ "/\\." member? ] rtrim ;

USE: io.windows.nt.backend
USE: io.windows.nt.files
USE: io.windows.nt.sockets

T{ windows-nt-io } io-backend set-global

M: windows-nt-io init-io ( -- )
    #! Should only be called on startup. Calling this at any
    #! other time can have unintended consequences.
    global [
        master-completion-port \ master-completion-port set
        H{ } clone \ io-hash set
        init-winsock
    ] bind ;

