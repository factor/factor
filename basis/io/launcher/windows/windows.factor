! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations io
io.backend.windows io.pipes.windows.nt io.pathnames libc
io.ports windows.types math windows.kernel32 namespaces make
io.launcher kernel sequences windows.errors splitting system
threads init strings combinators io.backend accessors
concurrency.flags io.files assocs io.files.private windows
destructors classes classes.struct specialized-arrays ;
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
        STARTUPINFO <struct>
        dup class heap-size >>cb
    >>lpStartupInfo
    PROCESS_INFORMATION <struct> >>lpProcessInformation
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

: escape-argument ( str -- newstr )
    CHAR: \s over member? [
        fix-trailing-backslashes "\"" dup surround
    ] when ;

: join-arguments ( args -- cmd-line )
    [ escape-argument ] map " " join ;

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

: app-name/cmd-line ( process -- app-name cmd-line )
    command>> dup string? [
        " " split1
    ] [
        unclip swap join-arguments
    ] if ;

: cmd-line ( process -- cmd-line )
    command>> dup string? [ join-arguments ] unless ;

: fill-lpApplicationName ( process args -- process args )
    over app-name/cmd-line
    [ >>lpApplicationName ] [ >>lpCommandLine ] bi* ;

: fill-lpCommandLine ( process args -- process args )
    over cmd-line >>lpCommandLine ;

: fill-dwCreateFlags ( process args -- process args )
    0
    pick pass-environment? [ CREATE_UNICODE_ENVIRONMENT bitor ] when
    pick detached>> os winnt? and [ DETACHED_PROCESS bitor ] when
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
    dup lpStartupInfo>> STARTF_USESTDHANDLES >>dwFlags drop ;

HOOK: fill-redirection io-backend ( process args -- )

M: wince fill-redirection 2drop ;

: make-CreateProcess-args ( process -- args )
    default-CreateProcess-args
    os wince? [ fill-lpApplicationName ] [ fill-lpCommandLine ] if
    fill-dwCreateFlags
    fill-lpEnvironment
    fill-startup-info
    nip ;

M: windows current-process-handle ( -- handle )
    GetCurrentProcessId ;

M: windows run-process* ( process -- handle )
    [
        current-directory get absolute-path cd

        dup make-CreateProcess-args
        tuck fill-redirection
        dup call-CreateProcess
        lpProcessInformation>>
    ] with-destructors ;

M: windows kill-process* ( handle -- )
    hProcess>> 255 TerminateProcess win32-error=0/f ;

: dispose-process ( process-information -- )
    #! From MSDN: "Handles in PROCESS_INFORMATION must be closed
    #! with CloseHandle when they are no longer needed."
    [ hProcess>> [ CloseHandle drop ] when* ]
    [ hThread>> [ CloseHandle drop ] when* ] bi ;

: exit-code ( process -- n )
    hProcess>>
    0 <ulong> [ GetExitCodeProcess ] keep *ulong
    swap win32-error=0/f ;

: process-exited ( process -- )
    dup handle>> exit-code
    over handle>> dispose-process
    notify-exit ;

M: windows wait-for-processes ( -- ? )
    processes get keys dup
    [ handle>> hProcess>> ] void*-array{ } map-as
    [ length ] keep 0 0
    WaitForMultipleObjects
    dup HEX: ffffffff = [ win32-error ] when
    dup WAIT_TIMEOUT = [ 2drop t ] [ swap nth process-exited f ] if ;
