USING: accessors alien alien.c-types alien.data alien.syntax
arrays byte-arrays classes.struct destructors fry io
io.encodings.string io.encodings.utf16n kernel literals locals
math nested-comments sequences strings system tools.ps
windows.errors windows.handles windows.kernel32 windows.ntdll
windows.types ;
IN: tools.ps.windows

: do-snapshot ( snapshot-type -- handle )
    0 CreateToolhelp32Snapshot dup win32-error=0/f ;

: default-process-entry ( -- obj )
    PROCESSENTRY32 <struct> PROCESSENTRY32 heap-size >>dwSize ;

: first-process ( handle -- PROCESSENTRY32 )
    default-process-entry
    [ Process32First win32-error=0/f ] keep ;

: next-process ( handle -- PROCESSENTRY32/f )
    default-process-entry [ Process32Next ] keep swap
    FALSE = [ drop f ] when ;

: open-process-read ( dwProcessId -- HANDLE )
    [
        flags{ PROCESS_QUERY_INFORMATION PROCESS_VM_READ }
        FALSE
    ] dip OpenProcess ;

: query-information-process ( HANDLE -- PROCESS_BASIC_INFORMATION )
    0
    PROCESS_BASIC_INFORMATION <struct> [
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

: slot-offset-by-name ( struct-class name -- value/f )
    [ struct-slots ] dip '[ name>> _ = ] find swap [ offset>> ] when ;

:: read-args ( handle -- string/f )
    handle <win32-handle> &dispose drop
    handle query-information-process :> process-basic-information
    handle process-basic-information PebBaseAddress>>
    [
        PEB "ProcessParameters" slot-offset-by-name
        PVOID heap-size
        read-process-memory
        PVOID deref :> args-offset
        args-offset ALIEN: 0 = [
            f
        ] [
            handle
            args-offset
            RTL_USER_PROCESS_PARAMETERS "CommandLine" slot-offset-by-name
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
            [ th32ProcessID>> ]
            [ th32ProcessID>> open-process-read dup [ read-args ] when ]
            [ szExeFile>> [ 0 = ] trim-tail >string or ] tri 2array
        ] map
    ] with-destructors ;

M: windows ps ( -- assoc ) process-list ;
