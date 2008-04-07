! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations destructors io
io.windows libc io.nonblocking io.streams.duplex windows.types
math windows.kernel32 windows namespaces io.launcher kernel
sequences windows.errors assocs splitting system strings
io.windows.launcher io.windows.nt.pipes io.backend io.files
io.files.private combinators shuffle accessors locals ;
IN: io.windows.nt.launcher

: duplicate-handle ( handle -- handle' )
    GetCurrentProcess ! source process
    swap ! handle
    GetCurrentProcess ! target process
    f <void*> [ ! target handle
        DUPLICATE_SAME_ACCESS ! desired access
        TRUE ! inherit handle
        DUPLICATE_CLOSE_SOURCE ! options
        DuplicateHandle win32-error=0/f
    ] keep *void* ;

! The below code is based on the example given in
! http://msdn2.microsoft.com/en-us/library/ms682499.aspx

: redirect-default ( default obj access-mode create-mode -- handle )
    3drop ;

: redirect-inherit ( default obj access-mode create-mode -- handle )
    4drop f ;

: redirect-closed ( default obj access-mode create-mode -- handle )
    drop 2nip null-pipe ;

:: redirect-file ( default path access-mode create-mode -- handle )
    path normalize-path
    access-mode
    share-mode
    security-attributes-inherit
    create-mode
    FILE_ATTRIBUTE_NORMAL ! flags and attributes
    f ! template file
    CreateFile dup invalid-handle? dup close-always ;

: set-inherit ( handle ? -- )
    >r HANDLE_FLAG_INHERIT r> >BOOLEAN SetHandleInformation win32-error=0/f ;

: redirect-stream ( default stream access-mode create-mode -- handle )
    2drop nip
    underlying-handle win32-file-handle
    duplicate-handle dup t set-inherit ;

: redirect ( default obj access-mode create-mode -- handle )
    {
        { [ pick not ] [ redirect-default ] }
        { [ pick +inherit+ eq? ] [ redirect-inherit ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick string? ] [ redirect-file ] }
        { [ t ] [ redirect-stream ] }
    } cond ;

: default-stdout ( args -- handle )
    stdout-pipe>> dup [ pipe-out ] when ;

: redirect-stdout ( process args -- handle )
    default-stdout
    swap stdout>>
    GENERIC_WRITE
    CREATE_ALWAYS
    redirect
    STD_OUTPUT_HANDLE GetStdHandle or ;

: redirect-stderr ( process args -- handle )
    over stderr>> +stdout+ eq? [
        lpStartupInfo>>
        STARTUPINFO-hStdOutput
        nip
    ] [
        drop
        f
        swap stderr>>
        GENERIC_WRITE
        CREATE_ALWAYS
        redirect
        STD_ERROR_HANDLE GetStdHandle or
    ] if ;

: default-stdin ( args -- handle )
    stdin-pipe>> dup [ pipe-in ] when ;

: redirect-stdin ( process args -- handle )
    default-stdin
    swap stdin>>
    GENERIC_READ
    OPEN_EXISTING
    redirect
    STD_INPUT_HANDLE GetStdHandle or ;

: add-pipe-dtors ( pipe -- )
    dup
    in>> close-later
    out>> close-later ;

: fill-stdout-pipe ( args -- args )
    <unique-incoming-pipe>
    dup add-pipe-dtors
    dup pipe-in f set-inherit
    >>stdout-pipe ;

: fill-stdin-pipe ( args -- args )
    <unique-outgoing-pipe>
    dup add-pipe-dtors
    dup pipe-out f set-inherit
    >>stdin-pipe ;

M: winnt fill-redirection ( process args -- )
    [ 2dup redirect-stdout ] keep lpStartupInfo>> set-STARTUPINFO-hStdOutput
    [ 2dup redirect-stderr ] keep lpStartupInfo>> set-STARTUPINFO-hStdError
    [ 2dup redirect-stdin  ] keep lpStartupInfo>> set-STARTUPINFO-hStdInput
    2drop ;

M: winnt (process-stream)
    [
        current-directory get (normalize-path) cd

        dup make-CreateProcess-args

        fill-stdout-pipe
        fill-stdin-pipe

        tuck fill-redirection

        dup call-CreateProcess

        dup stdin-pipe>> pipe-in CloseHandle drop
        dup stdout-pipe>> pipe-out CloseHandle drop

        dup lpProcessInformation>>
        over stdout-pipe>> in>> f <win32-file>
        rot stdin-pipe>> out>> f <win32-file>
    ] with-destructors ;
