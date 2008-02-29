! Copyright (C) 2007 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations destructors io
io.windows libc io.nonblocking io.streams.duplex windows.types
math windows.kernel32 windows namespaces io.launcher kernel
sequences windows.errors assocs splitting system strings
io.windows.launcher io.windows.nt.pipes io.backend
combinators ;
IN: io.windows.nt.launcher

! The below code is based on the example given in
! http://msdn2.microsoft.com/en-us/library/ms682499.aspx

: (redirect) ( path access-mode create-mode -- handle )
    >r >r
    normalize-pathname
    r> ! access-mode
    share-mode
    security-attributes-inherit
    r> ! create-mode
    FILE_ATTRIBUTE_NORMAL ! flags and attributes
    f ! template file
    CreateFile dup invalid-handle? dup close-later ;

: redirect ( obj access-mode create-mode -- handle )
    {
        { [ pick not ] [ 3drop f ] }
        { [ pick +closed+ eq? ] [ drop nip null-pipe ] }
        { [ pick string? ] [ (redirect) ] }
    } cond ;

: ?closed or dup t eq? [ drop f ] when ;

: inherited-stdout ( args -- handle )
    CreateProcess-args-stdout-pipe
    [ pipe-out ] [ STD_OUTPUT_HANDLE GetStdHandle ] if* ;

: redirect-stdout ( args -- handle )
    +stdout+ get GENERIC_WRITE CREATE_ALWAYS redirect
    swap inherited-stdout ?closed ;

: inherited-stderr ( args -- handle )
    drop STD_ERROR_HANDLE GetStdHandle ;

: redirect-stderr ( args -- handle )
    +stderr+ get
    dup +stdout+ eq? [
        drop
        CreateProcess-args-lpStartupInfo STARTUPINFO-hStdOutput
    ] [
        GENERIC_WRITE CREATE_ALWAYS redirect
        swap inherited-stderr ?closed
    ] if ;

: inherited-stdin ( args -- handle )
    CreateProcess-args-stdin-pipe
    [ pipe-in ] [ STD_INPUT_HANDLE GetStdHandle ] if* ;

: redirect-stdin ( args -- handle )
    +stdin+ get GENERIC_READ OPEN_EXISTING redirect
    swap inherited-stdin ?closed ;

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

M: windows-nt-io fill-redirection
    dup CreateProcess-args-lpStartupInfo
    over redirect-stdout over set-STARTUPINFO-hStdOutput
    over redirect-stderr over set-STARTUPINFO-hStdError
    over redirect-stdin over set-STARTUPINFO-hStdInput
    drop ;

M: windows-nt-io process-stream*
    [
        [
            make-CreateProcess-args

            fill-stdout-pipe
            fill-stdin-pipe

            fill-redirection

            dup call-CreateProcess

            dup CreateProcess-args-stdin-pipe pipe-in CloseHandle drop
            dup CreateProcess-args-stdout-pipe pipe-out CloseHandle drop

            dup CreateProcess-args-stdout-pipe pipe-in
            over CreateProcess-args-stdin-pipe pipe-out <win32-duplex-stream>

            swap CreateProcess-args-lpProcessInformation <process>
        ] with-destructors
    ] with-descriptor ;
