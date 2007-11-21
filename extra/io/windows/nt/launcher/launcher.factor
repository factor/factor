! Copyright (C) 2007 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations destructors io
io.windows libc io.nonblocking io.streams.duplex windows.types
math windows.kernel32 windows namespaces io.launcher kernel
sequences windows.errors assocs splitting system
io.windows.launcher io.windows.nt.pipes ;
IN: io.windows.nt.launcher

! The below code is based on the example given in
! http://msdn2.microsoft.com/en-us/library/ms682499.aspx

: set-inherit ( handle ? -- )
    >r HANDLE_FLAG_INHERIT r> >BOOLEAN SetHandleInformation win32-error=0/f ;

: add-pipe-dtors ( pipe -- )
    dup
    pipe-in close-later
    pipe-out close-later ;

: fill-stdout-pipe
    <unique-incoming-pipe>
    dup add-pipe-dtors
    dup pipe-in f set-inherit
    over set-CreateProcess-args-stdout-pipe ;

: fill-stdin-pipe
    <unique-outgoing-pipe>
    dup add-pipe-dtors
    dup pipe-out f set-inherit
    over set-CreateProcess-args-stdin-pipe ;

: fill-startup-info
    dup CreateProcess-args-lpStartupInfo
    STARTF_USESTDHANDLES over set-STARTUPINFO-dwFlags

    over CreateProcess-args-stdout-pipe
        pipe-out over set-STARTUPINFO-hStdOutput
    over CreateProcess-args-stdout-pipe
        pipe-out over set-STARTUPINFO-hStdError
    over CreateProcess-args-stdin-pipe
        pipe-in swap set-STARTUPINFO-hStdInput ;

M: windows-io process-stream*
    [
        [
            make-CreateProcess-args
            TRUE over set-CreateProcess-args-bInheritHandles

            fill-stdout-pipe
            fill-stdin-pipe
            fill-startup-info

            dup call-CreateProcess

            dup CreateProcess-args-stdin-pipe pipe-in CloseHandle drop
            dup CreateProcess-args-stdout-pipe pipe-out CloseHandle drop

            dup CreateProcess-args-stdout-pipe pipe-in
            over CreateProcess-args-stdin-pipe pipe-out <win32-duplex-stream>

            swap dispose-CreateProcess-args
        ] with-destructors
    ] with-descriptor ;
