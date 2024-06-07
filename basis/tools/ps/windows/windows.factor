USING: accessors alien alien.c-types alien.data alien.syntax
arrays byte-arrays classes.struct combinators.short-circuit
continuations destructors fry io io.encodings.string
io.encodings.utf16 kernel literals locals math sequences
strings system tools.ps windows.errors windows.handles
windows.kernel32 windows.ntdll windows.types ;
IN: tools.ps.windows

: do-snapshot ( snapshot-type -- handle )
    0 CreateToolhelp32Snapshot dup win32-error=0/f ;

: default-process-entry ( -- obj )
    PROCESSENTRY32 new PROCESSENTRY32 heap-size >>dwSize ;

: first-process ( handle -- PROCESSENTRY32 )
    default-process-entry
    [ Process32First win32-error=0/f ] keep ;

: next-process ( handle -- PROCESSENTRY32/f )
    default-process-entry [ Process32Next ] guard
    FALSE = [ drop f ] when ;

: open-process-read ( dwProcessId -- HANDLE )
    [
        flags{ PROCESS_QUERY_INFORMATION PROCESS_VM_READ }
        FALSE
    ] dip OpenProcess ;

: query-information-process ( HANDLE -- PROCESS_BASIC_INFORMATION )
    0
    PROCESS_BASIC_INFORMATION new [
        dup byte-length
        f
        NtQueryInformationProcess drop
    ] keep ;

:: read-process-memory ( HANDLE alien offset len -- byte-array )
    HANDLE
    offset alien <displaced-alien>
    len <byte-array> dup :> ba
    len
    f
    ReadProcessMemory win32-error=0/f
    ba ;

: read-peb ( handle address -- peb )
    0 PEB heap-size read-process-memory PEB memory>struct ;

: my-peb ( -- peb )
    GetCurrentProcessId [
        open-process-read
        [ <win32-handle> &dispose drop ]
        [ dup query-information-process PebBaseAddress>> read-peb ] bi
    ] with-destructors ;

:: read-args ( handle -- string/f )
    handle <win32-handle> &dispose drop
    handle query-information-process :> process-basic-information
    handle process-basic-information PebBaseAddress>>
    [
        "ProcessParameters" PEB offset-of
        PVOID heap-size
        read-process-memory
        PVOID deref :> args-offset
        args-offset ALIEN: 0 = [
            f
        ] [
            handle
            args-offset
            "CommandLine" RTL_USER_PROCESS_PARAMETERS offset-of
            UNICODE_STRING heap-size
            read-process-memory
            [ handle ] dip
            UNICODE_STRING deref [ Buffer>> 0 ] [ Length>> ] bi read-process-memory
            utf16n decode
        ] if
    ] [ drop f ] if* ;

: process-list ( -- assoc )
    [
        TH32CS_SNAPALL do-snapshot
        [ <win32-handle> &dispose drop ]
        [ first-process ]
        [ '[ drop _ next-process ] follow ] tri
        [
            [
                [ th32ProcessID>> ]
                [ th32ProcessID>> open-process-read dup [ read-args ] when ]
                [ szExeFile>> [ 0 = ] trim-tail >string or ] tri 2array
            ] [
                ! Reading the arguments can fail
                ! Win32 error 0x12b: Only part of a ReadProcessMemory or WriteProcessMemory request was completed.
                dup { [ windows-error? ] [ n>> 0x12b = ] } 1&& [ 2drop f ] [ rethrow ] if
            ] recover
        ] map sift
    ] with-destructors ;

M: windows ps process-list ;
