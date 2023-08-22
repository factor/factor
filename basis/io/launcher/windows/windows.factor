! Copyright (C) 2007, 2010 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs
classes classes.struct combinators combinators.short-circuit
concurrency.flags continuations debugger destructors init io
io.backend io.backend.windows io.files io.files.private
io.files.windows io.launcher io.launcher.private io.pathnames
io.pipes io.pipes.windows io.ports kernel libc literals locals
make math namespaces prettyprint sequences specialized-arrays
splitting splitting.monotonic strings system threads windows
windows.errors windows.handles windows.kernel32 windows.types
windows.user32 ;
SPECIALIZED-ARRAY: ushort
SPECIALIZED-ARRAY: void*
IN: io.launcher.windows

TUPLE: CreateProcess-args
       lpApplicationName
       lpCommandLine
       lpProcessAttributes
       lpThreadAttributes
       bInheritHandles
       dwCreateFlags
       lpEnvironment
       lpCurrentDirectory
       lpStartupInfo
       lpProcessInformation ;

: default-CreateProcess-args ( -- obj )
    CreateProcess-args new
        STARTUPINFO new
        dup class-of heap-size >>cb
    >>lpStartupInfo
    PROCESS_INFORMATION new >>lpProcessInformation
    TRUE >>bInheritHandles
    0 >>dwCreateFlags ;

: call-CreateProcess ( CreateProcess-args -- )
    {
        [ lpApplicationName>> ]
        [ lpCommandLine>> ]
        [ lpProcessAttributes>> ]
        [ lpThreadAttributes>> ]
        [ bInheritHandles>> ]
        [ dwCreateFlags>> ]
        [ lpEnvironment>> ]
        [ lpCurrentDirectory>> ]
        [ lpStartupInfo>> ]
        [ lpProcessInformation>> ]
    } cleave
    CreateProcess win32-error=0/f ;

: count-trailing-backslashes ( str n -- str n )
    [ "\\" ?tail ] dip swap [
        1 + count-trailing-backslashes
    ] when ;

: fix-trailing-backslashes ( str -- str' )
    0 count-trailing-backslashes
    2 * CHAR: \\ <repetition> append ;

! Find groups of \, groups of \ followed by ", or naked "
: escape-double-quote ( str -- newstr )
    [
        { [ drop CHAR: \ = ] [ nip "\\\"" member? ] } 2&&
    ] monotonic-split [
        dup last CHAR: \" = [
            dup length 1 > [
                ! String of backslashes + double-quote
                length 1 - 2 * CHAR: \\ <repetition> "\\\"" append
            ] [
                ! Single double-quote
                drop "\\\""
            ] if
        ] when
    ] map "" concat-as ;

! Naked double-quotes get a backslash before them
! Backslashes before a double-quote get doubled in the output
! If there's a space, double trailing backslashes and surround by quotes
! See https://msdn.microsoft.com/en-us/library/ms647232.aspx
: escape-argument ( str -- newstr )
    escape-double-quote
    CHAR: \s over member? [
        fix-trailing-backslashes "\"" 1surround
    ] when ;

: join-arguments ( args -- cmd-line )
    [ escape-argument ] map join-words ;

: lookup-priority ( process -- n )
    priority>> {
        { +lowest-priority+ [ IDLE_PRIORITY_CLASS ] }
        { +low-priority+ [ BELOW_NORMAL_PRIORITY_CLASS ] }
        { +normal-priority+ [ NORMAL_PRIORITY_CLASS ] }
        { +high-priority+ [ ABOVE_NORMAL_PRIORITY_CLASS ] }
        { +highest-priority+ [ HIGH_PRIORITY_CLASS ] }
        { +realtime-priority+ [ REALTIME_PRIORITY_CLASS ] }
        [ drop f ]
    } case ;

: cmd-line ( process -- cmd-line )
    command>> dup string? [ join-arguments ] unless ;

: fill-lpCommandLine ( process args -- process args )
    over cmd-line >>lpCommandLine ;

: fill-dwCreateFlags ( process args -- process args )
    0
    pick pass-environment? [ CREATE_UNICODE_ENVIRONMENT bitor ] when
    pick group>> [
        {
            { +same-group+ [ ] }
            { +new-session+ [ CREATE_NEW_PROCESS_GROUP bitor ] }
            { +new-group+ [ CREATE_NEW_PROCESS_GROUP bitor ] }
            [ drop ]
        } case
    ] when*
    pick lookup-priority [ bitor ] when*
    >>dwCreateFlags ;

: fill-lpEnvironment ( process args -- process args )
    over pass-environment? [
        [
            over get-environment
            [ swap % "=" % % "\0" % ] assoc-each
            "\0" %
        ] ushort-array{ } make
        >>lpEnvironment
    ] when ;

: fill-startup-info ( process args -- process args )
    over hidden>> [ dup lpStartupInfo>> ] dip
    [
        flags{ STARTF_USESTDHANDLES STARTF_USESHOWWINDOW } >>dwFlags
        SW_HIDE >>wShowWindow
    ] [
        STARTF_USESTDHANDLES >>dwFlags
    ] if drop ;

: make-CreateProcess-args ( process -- args )
    default-CreateProcess-args
    fill-lpCommandLine
    fill-dwCreateFlags
    fill-lpEnvironment
    fill-startup-info
    nip ;

M: windows (current-process)
    GetCurrentProcessId ;

ERROR: launch-error process error ;

M: launch-error error.
    "Launching failed with error:" print
    dup error>> error. nl
    "Launch descriptor:" print nl
    process>> . ;

M: windows (kill-process)
    handle>> hProcess>> 255 TerminateProcess win32-error=0/f ;

: dispose-process ( process-information -- )
    ! From MSDN: "Handles in PROCESS_INFORMATION must be closed
    ! with CloseHandle when they are no longer needed."
    [ hProcess>> [ CloseHandle drop ] when* ]
    [ hThread>> [ CloseHandle drop ] when* ] bi ;

: exit-code ( process -- n )
    hProcess>>
    { DWORD } [ GetExitCodeProcess ] with-out-parameters
    swap win32-error=0/f ;

: process-exited ( process -- )
    dup handle>> exit-code
    over handle>> dispose-process
    notify-exit ;

M: windows (wait-for-processes)
    processes get keys dup
    [ handle>> hProcess>> ] void*-array{ } map-as
    [ length ] keep 0 0
    WaitForMultipleObjects
    dup 0xffffffff = [ win32-error ] when
    dup WAIT_TIMEOUT = [ 2drop t ] [ swap nth process-exited f ] if ;

: duplicate-handle ( handle -- handle' )
    GetCurrentProcess ! source process
    swap handle>> ! handle
    GetCurrentProcess ! target process
    f void* <ref> [ ! target handle
        DUPLICATE_SAME_ACCESS ! desired access
        TRUE ! inherit handle
        0 ! options
        DuplicateHandle win32-error=0/f
    ] keep void* deref <win32-handle> &dispose ;

! /dev/null simulation
: null-input ( -- pipe )
    (pipe) [ in>> &dispose ] [ out>> dispose ] bi ;

: null-output ( -- pipe )
    (pipe) [ out>> &dispose ] [ in>> dispose ] bi ;

: null-pipe ( mode -- pipe )
    {
        { GENERIC_READ [ null-input ] }
        { GENERIC_WRITE [ null-output ] }
    } case ;

! The below code is based on the example given in
! https://msdn2.microsoft.com/en-us/library/ms682499.aspx

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
    CreateFile check-invalid-handle <win32-file> &dispose ;

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

: fill-redirection ( process args -- )
    dup lpStartupInfo>>
    [ [ redirect-stdout ] dip hStdOutput<< ]
    [ [ redirect-stderr ] dip hStdError<< ]
    [ [ redirect-stdin ] dip hStdInput<< ] 3tri ;

M: windows (run-process)
    [
        [
            dup make-CreateProcess-args
            current-directory get absolute-path >>lpCurrentDirectory
            [ fill-redirection ] keep
            dup call-CreateProcess
            lpProcessInformation>>
        ] with-destructors
    ] [ launch-error ] recover ;
