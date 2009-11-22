! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations destructors io
io.backend.windows libc io.ports io.pipes windows.types math
windows.kernel32 windows namespaces make io.launcher kernel
sequences windows.errors assocs splitting system strings
io.launcher.windows io.files.windows io.backend io.files
io.files.private combinators shuffle accessors locals ;
IN: io.launcher.windows.nt

: duplicate-handle ( handle -- handle' )
    GetCurrentProcess ! source process
    swap handle>> ! handle
    GetCurrentProcess ! target process
    f <void*> [ ! target handle
        DUPLICATE_SAME_ACCESS ! desired access
        TRUE ! inherit handle
        0 ! options
        DuplicateHandle win32-error=0/f
    ] keep *void* <win32-handle> &dispose ;

! /dev/null simulation
: null-input ( -- pipe )
    (pipe) [ in>> &dispose ] [ out>> dispose ] bi ;

: null-output ( -- pipe )
    (pipe) [ in>> dispose ] [ out>> &dispose ] bi ;

: null-pipe ( mode -- pipe )
    {
        { GENERIC_READ [ null-input ] }
        { GENERIC_WRITE [ null-output ] }
    } case ;

! The below code is based on the example given in
! http://msdn2.microsoft.com/en-us/library/ms682499.aspx

: redirect-default ( obj access-mode create-mode -- handle )
    3drop f ;

: redirect-closed ( obj access-mode create-mode -- handle )
    drop nip null-pipe ;

:: redirect-file ( path access-mode create-mode -- handle )
    path normalize-path
    access-mode
    share-mode
    default-security-attributes
    create-mode
    FILE_ATTRIBUTE_NORMAL ! flags and attributes
    f ! template file
    CreateFile dup invalid-handle? <win32-file> &dispose ;

: redirect-append ( path access-mode create-mode -- handle )
    [ path>> ] 2dip
    drop OPEN_ALWAYS
    redirect-file
    dup 0 FILE_END set-file-pointer ;

: redirect-handle ( handle access-mode create-mode -- handle )
    2drop ;

: redirect-stream ( stream access-mode create-mode -- handle )
    [ underlying-handle ] 2dip redirect-handle ;

: redirect ( obj access-mode create-mode -- handle )
    {
        { [ pick not ] [ redirect-default ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick appender? ] [ redirect-append ] }
        { [ pick win32-file? ] [ redirect-handle ] }
        [ redirect-stream ]
    } cond
    dup [ dup t set-inherit handle>> ] when ;

: redirect-stdout ( process args -- handle )
    drop
    stdout>>
    GENERIC_WRITE
    CREATE_ALWAYS
    redirect
    STD_OUTPUT_HANDLE GetStdHandle or ;

: redirect-stderr ( process args -- handle )
    over stderr>> +stdout+ eq? [
        nip
        lpStartupInfo>> hStdOutput>>
    ] [
        drop
        stderr>>
        GENERIC_WRITE
        CREATE_ALWAYS
        redirect
        STD_ERROR_HANDLE GetStdHandle or
    ] if ;

: redirect-stdin ( process args -- handle )
    drop
    stdin>>
    GENERIC_READ
    OPEN_EXISTING
    redirect
    STD_INPUT_HANDLE GetStdHandle or ;

M: winnt fill-redirection ( process args -- )
    dup lpStartupInfo>>
    [ [ redirect-stdout ] dip (>>hStdOutput) ]
    [ [ redirect-stderr ] dip (>>hStdError) ]
    [ [ redirect-stdin ] dip (>>hStdInput) ] 3tri ;
