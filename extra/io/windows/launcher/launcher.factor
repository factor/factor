! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays continuations destructors io
io.windows io.windows.nt.pipes libc io.nonblocking
io.streams.duplex windows.types math windows.kernel32 windows
namespaces io.launcher kernel sequences windows.errors assocs
splitting system threads init strings combinators
io.backend accessors concurrency.flags io.files ;
IN: io.windows.launcher

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
       lpProcessInformation
       stdout-pipe stdin-pipe ;

: default-CreateProcess-args ( -- obj )
    CreateProcess-args construct-empty
    0 >>dwCreateFlags
    "STARTUPINFO" <c-object>
    "STARTUPINFO" heap-size over set-STARTUPINFO-cb >>lpStartupInfo
    "PROCESS_INFORMATION" <c-object> >>lpProcessInformation
    TRUE >>bInheritHandles
    current-directory get >>lpCurrentDirectory ;

: call-CreateProcess ( CreateProcess-args -- )
    {
        lpApplicationName>>
        lpCommandLine>>
        lpProcessAttributes>>
        lpThreadAttributes>>
        bInheritHandles>>
        dwCreateFlags>>
        lpEnvironment>>
        lpCurrentDirectory>>
        lpStartupInfo>>
        lpProcessInformation>>
    } get-slots CreateProcess win32-error=0/f ;

: escape-argument ( str -- newstr )
    CHAR: \s over member? [ "\"" swap "\"" 3append ] when ;

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
    >r >>lpApplicationName
    r> >>lpCommandLine ;

: fill-lpCommandLine ( process args -- process args )
    over cmd-line >>lpCommandLine ;

: fill-dwCreateFlags ( process args -- process args )
    0
    pick pass-environment? [ CREATE_UNICODE_ENVIRONMENT bitor ] when
    pick detached>> winnt? and [ DETACHED_PROCESS bitor ] when
    pick lookup-priority [ bitor ] when*
    >>dwCreateFlags ;

: fill-lpEnvironment ( process args -- process args )
    over pass-environment? [
        [
            over get-environment
            [ swap % "=" % % "\0" % ] assoc-each
            "\0" %
        ] "" make >c-ushort-array
        >>lpEnvironment
    ] when ;

: fill-startup-info ( process args -- process args )
    STARTF_USESTDHANDLES over lpStartupInfo>> set-STARTUPINFO-dwFlags ;

HOOK: fill-redirection io-backend ( process args -- )

M: windows-ce-io fill-redirection 2drop ;

: make-CreateProcess-args ( process -- args )
    default-CreateProcess-args
    wince? [ fill-lpApplicationName ] [ fill-lpCommandLine ] if
    fill-dwCreateFlags
    fill-lpEnvironment
    fill-startup-info
    nip ;

M: windows-io current-process-handle ( -- handle )
    GetCurrentProcessId ;

M: windows-io run-process* ( process -- handle )
    [
        dup make-CreateProcess-args
        tuck fill-redirection
        dup call-CreateProcess
        lpProcessInformation>>
    ] with-destructors ;

M: windows-io kill-process* ( handle -- )
    PROCESS_INFORMATION-hProcess
    255 TerminateProcess win32-error=0/f ;

: dispose-process ( process-information -- )
    #! From MSDN: "Handles in PROCESS_INFORMATION must be closed
    #! with CloseHandle when they are no longer needed."
    dup PROCESS_INFORMATION-hProcess [ CloseHandle drop ] when*
    PROCESS_INFORMATION-hThread [ CloseHandle drop ] when* ;

: exit-code ( process -- n )
    PROCESS_INFORMATION-hProcess
    0 <ulong> [ GetExitCodeProcess ] keep *ulong
    swap win32-error=0/f ;

: process-exited ( process -- )
    dup process-handle exit-code
    over process-handle dispose-process
    notify-exit ;

: wait-for-processes ( processes -- ? )
    keys dup
    [ process-handle PROCESS_INFORMATION-hProcess ] map
    dup length swap >c-void*-array 0 0
    WaitForMultipleObjects
    dup HEX: ffffffff = [ win32-error ] when
    dup WAIT_TIMEOUT = [ 2drop t ] [ swap nth process-exited f ] if ;

SYMBOL: wait-flag

: wait-loop ( -- )
    processes get dup assoc-empty?
    [ drop wait-flag get-global lower-flag ]
    [ wait-for-processes [ 100 sleep ] when ] if ;

: start-wait-thread ( -- )
    <flag> wait-flag set-global
    [ wait-loop t ] "Process wait" spawn-server drop ;

M: windows-io register-process
    drop wait-flag get-global raise-flag ;

[ start-wait-thread ] "io.windows.launcher" add-init-hook
