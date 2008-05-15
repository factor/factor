! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations destructors io
io.windows libc io.ports io.pipes windows.types
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

! /dev/null simulation
: null-input ( -- pipe )
    (pipe) [ in>> handle>> ] [ out>> close-handle ] bi ;

: null-output ( -- pipe )
    (pipe) [ in>> close-handle ] [ out>> handle>> ] bi ;

: null-pipe ( mode -- pipe )
    {
        { GENERIC_READ [ null-input ] }
        { GENERIC_WRITE [ null-output ] }
    } case ;

! The below code is based on the example given in
! http://msdn2.microsoft.com/en-us/library/ms682499.aspx

: redirect-default ( default obj access-mode create-mode -- handle )
    3drop ;

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
    CreateFile dup invalid-handle? &close-handle ;

: redirect-append ( default path access-mode create-mode -- handle )
    >r >r path>> r> r>
    drop OPEN_ALWAYS
    redirect-file
    dup 0 FILE_END set-file-pointer ;

: set-inherit ( handle ? -- )
    >r HANDLE_FLAG_INHERIT r> >BOOLEAN SetHandleInformation win32-error=0/f ;

: redirect-handle ( default handle access-mode create-mode -- handle )
    2drop nip
    handle>> duplicate-handle dup t set-inherit ;

: redirect-stream ( default stream access-mode create-mode -- handle )
    >r >r underlying-handle r> r> redirect-handle ;

: redirect ( default obj access-mode create-mode -- handle )
    {
        { [ pick not ] [ redirect-default ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick appender? ] [ redirect-append ] }
        { [ pick win32-file? ] [ redirect-handle ] }
        [ redirect-stream ]
    } cond ;

: default-stdout ( args -- handle )
    stdout-pipe>> dup [ out>> ] when ;

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
    stdin-pipe>> dup [ in>> ] when ;

: redirect-stdin ( process args -- handle )
    default-stdin
    swap stdin>>
    GENERIC_READ
    OPEN_EXISTING
    redirect
    STD_INPUT_HANDLE GetStdHandle or ;

M: winnt fill-redirection ( process args -- )
    [ 2dup redirect-stdout ] keep lpStartupInfo>> set-STARTUPINFO-hStdOutput
    [ 2dup redirect-stderr ] keep lpStartupInfo>> set-STARTUPINFO-hStdError
    [ 2dup redirect-stdin  ] keep lpStartupInfo>> set-STARTUPINFO-hStdInput
    2drop ;
