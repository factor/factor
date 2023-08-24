! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays
classes.struct destructors endian kernel literals sequences
strings windows windows.errors windows.handles windows.kernel32
windows.types ;
IN: windows.processes

: with-open-process ( access 1/0 processid quot -- )
    [ OpenProcess dup win32-error=0/f ] dip
    '[ _ <win32-handle> &dispose @ ] with-destructors ; inline

: with-open-process-all-access ( processid quot -- )
    [ PROCESS_ALL_ACCESS FALSE ] 2dip with-open-process ; inline

: with-create-toolhelp32-snapshot ( flags processId quot: ( alien -- alien ) -- )
    [ CreateToolhelp32Snapshot dup win32-error=0/f ] dip
    '[
        _ [ <win32-handle> &dispose drop ] keep @
    ] with-destructors ; inline

: with-create-toolhelp32-snapshot-processes ( quot: ( alien -- processes ) -- )
    [ TH32CS_SNAPPROCESS 0 ] dip with-create-toolhelp32-snapshot ; inline

: with-create-toolhelp32-snapshot-modules ( processId quot: ( alien -- processes ) -- )
    [ TH32CS_SNAPMODULE ] 2dip with-create-toolhelp32-snapshot ; inline

: with-create-toolhelp32-snapshot-threads ( processId quot: ( alien -- processes ) -- )
    [ TH32CS_SNAPTHREAD ] 2dip with-create-toolhelp32-snapshot ; inline

: with-create-toolhelp32-snapshot-heaplists ( quot: ( alien -- heaplists ) -- )
    [ TH32CS_SNAPHEAPLIST GetCurrentProcessId ] dip with-create-toolhelp32-snapshot ; inline

: check-snapshot ( n -- continue? )
    ${ ERROR_NO_MORE_FILES } win32-error=0/f-allowed 1 = ;

: get-process-list ( -- processes )
    [
        PROCESSENTRY32 <struct> [ dup byte-length >>dwSize Process32FirstW check-snapshot ] 2keep rot [
            [
                [
                    PROCESSENTRY32 <struct> [
                        dup byte-length >>dwSize Process32NextW
                        check-snapshot
                    ] 2keep rot
                ] [
                ] produce
            ] dip prefix 2nip
        ] [
            1array nip
        ] if
    ] with-create-toolhelp32-snapshot-processes ;

: get-process-modules ( dwPid -- processes )
    [
        MODULEENTRY32W <struct> [
            dup byte-length >>dwSize Module32FirstW check-snapshot ] 2keep rot [
            [
                [
                    MODULEENTRY32W <struct> [
                        dup byte-length >>dwSize
                        Module32NextW check-snapshot
                    ] 2keep rot
                ] [
                ] produce
            ] dip prefix 2nip
        ] [
            1array nip
        ] if
    ] with-create-toolhelp32-snapshot-modules ;

: get-process-threads ( dwPid -- processes )
    [
        THREADENTRY32 <struct> [
            dup byte-length >>dwSize Thread32First check-snapshot ] 2keep rot [
            [
                [
                    THREADENTRY32 <struct> [
                        dup byte-length >>dwSize
                        Thread32Next check-snapshot
                    ] 2keep rot
                ] [
                ] produce
            ] dip prefix 2nip
        ] [
            1array nip
        ] if
    ] with-create-toolhelp32-snapshot-threads ;

: get-heap-entries ( heapId -- heap-entries )
    [
        HEAPENTRY32 <struct> dup byte-length >>dwSize GetCurrentProcessId
    ] dip [ Heap32First check-snapshot ] 3keep 2drop dup clone rot
    [
        [
            [ Heap32Next check-snapshot ] keep swap
        ] [ dup clone ] produce swap prefix nip
    ] [
        1array nip
    ] if ;

: get-heap-lists ( -- heaplists )
    [
        HEAPLIST32 <struct> [ dup byte-length >>dwSize Heap32ListFirst check-snapshot ] 2keep rot [
            ! dup th32HeapID>> get-heap-entries describe
            [
                [
                    HEAPLIST32 <struct>
                    [ dup byte-length >>dwSize Heap32ListNext check-snapshot ] 2keep rot
                ] [
                ] produce
            ] dip prefix 2nip
        ] [
            2drop { }
        ] if
    ] with-create-toolhelp32-snapshot-heaplists ;

: get-process-image-name ( processId -- string )
    0 MAX_UNICODE_PATH
    [ uchar <c-array> ] [ DWORD <ref> ] bi
    [ QueryFullProcessImageNameA win32-error=0/f ] 2keep
    le> head >string ;

: get-my-process-image-name ( -- string )
    GetCurrentProcess get-process-image-name ;
