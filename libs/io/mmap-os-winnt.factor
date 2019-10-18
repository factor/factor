USING: alien generic io-internals kernel libc libs-io math
namespaces nonblocking-io sequences win32-api ;
IN: mmap

: PAGE_NOACCESS	1 ; inline
: PAGE_READONLY	2 ; inline
: PAGE_READWRITE 4 ; inline
: PAGE_WRITECOPY 8 ; inline
: PAGE_EXECUTE HEX: 10 ; inline
: PAGE_EXECUTE_READ HEX: 20 ; inline
: PAGE_EXECUTE_READWRITE HEX: 40 ; inline
: PAGE_EXECUTE_WRITECOPY HEX: 80 ; inline
: PAGE_GUARD HEX: 100 ; inline
: PAGE_NOCACHE HEX: 200 ; inline

: SEC_BASED HEX: 00200000 ; inline
: SEC_NO_CHANGE HEX: 00400000 ; inline
: SEC_FILE HEX: 00800000 ; inline
: SEC_IMAGE HEX: 01000000 ; inline
: SEC_VLM HEX: 02000000 ; inline
: SEC_RESERVE HEX: 04000000 ; inline
: SEC_COMMIT HEX: 08000000 ; inline
: SEC_NOCACHE HEX: 10000000 ; inline
: MEM_IMAGE SEC_IMAGE ; inline

: ERROR_ALREADY_EXISTS 183 ; inline

: FILE_MAP_ALL_ACCESS HEX: f001f ;
: FILE_MAP_READ   4 ;
: FILE_MAP_WRITE  2 ;
: FILE_MAP_COPY   1 ;

TYPEDEF: TOKEN_PRIVILEGES* PTOKEN_PRIVILEGES

: lookup-privilege ( string -- luid )
    >r f r> "LUID" <c-object>
    [ LookupPrivilegeValue win32-error=0/f ] keep ;

: make-token-privileges ( name ? -- obj )
    "TOKEN_PRIVILEGES" <c-object>
    1 [ over set-TOKEN_PRIVILEGES-PrivilegeCount ] keep
    "LUID_AND_ATTRIBUTES" malloc-array over set-TOKEN_PRIVILEGES-Privileges

    swap [
        SE_PRIVILEGE_ENABLED over TOKEN_PRIVILEGES-Privileges
        set-LUID_AND_ATTRIBUTES-Attributes
    ] when

    >r lookup-privilege r>
    [
        TOKEN_PRIVILEGES-Privileges
        >r 0 r> LUID_AND_ATTRIBUTES-nth
        set-LUID_AND_ATTRIBUTES-Luid
    ] keep ;

: set-privilege ( name ? -- )
    [
        -rot 0 -rot make-token-privileges
        [
            dup length f f AdjustTokenPrivileges win32-error=0/f
        ] keep
        TOKEN_PRIVILEGES-Privileges free
    ] with-process-token ;

! : mmap-open ( path r w flProtect access -- address )
    ! { "SeCreateGlobalPrivilege" "SeLockMemoryPrivilege" } [
        ! >r >r open-file f r> 0 0 f
        ! CreateFileMapping [ win32-error=0/f ] keep
        ! r> 0 0 0 MapViewOfFile [ win32-error=0/f ] keep
    ! ] with-privileges ;

: mmap-open ( path r w flProtect access -- handle handle address )
    "SeCreateGlobalPrivilege" t set-privilege
    "SeLockMemoryPrivilege" t set-privilege
    >r >r open-file dup f r> 0 0 f CreateFileMapping
    [ win32-error=0/f ] keep
    dup
    r> 0 0 0 MapViewOfFile [ win32-error=0/f ] keep
    "SeLockMemoryPrivilege" f set-privilege
    "SeCreateGlobalPrivilege" f set-privilege ;
    
! : mmap-read ( path -- alien )
    ! t f PAGE_READONLY SEC_COMMIT bitor FILE_MAP_READ mmap-open ;

! : mmap-write
    ! f t PAGE_READWRITE SEC_COMMIT bitor FILE_MAP_WRITE mmap-open ;

TUPLE: mmap path hFile hMapping address ;

: mmap-r/w ( path -- mmap )
    dup
    t t PAGE_READWRITE SEC_COMMIT bitor FILE_MAP_ALL_ACCESS mmap-open
    <mmap> ;

: mmap-close ( alien -- )
    [ mmap-address UnmapViewOfFile win32-error=0/f ] keep
    [ mmap-hMapping close-handle ] keep
    mmap-hFile close-handle ;

