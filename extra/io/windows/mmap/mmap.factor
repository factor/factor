USING: alien alien.c-types alien.syntax arrays continuations
destructors generic io.mmap io.nonblocking io.windows
kernel libc math namespaces quotations sequences windows
windows.advapi32 windows.kernel32 ;
IN: io.windows.mmap

TYPEDEF: TOKEN_PRIVILEGES* PTOKEN_PRIVILEGES

! Security tokens
!  http://msdn.microsoft.com/msdnmag/issues/05/03/TokenPrivileges/

: (open-process-token) ( handle -- handle )
    TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY bitor "PHANDLE" <c-object>
    [ OpenProcessToken win32-error=0/f ] keep *void* ;

: open-process-token ( -- handle )
    #! remember to handle-close this
    GetCurrentProcess (open-process-token) ;

: with-process-token ( quot -- )
    #! quot: ( token-handle -- token-handle )
    >r open-process-token r>
    [ keep ] curry
    [ CloseHandle drop ] [ ] cleanup ; inline

: lookup-privilege ( string -- luid )
    >r f r> "LUID" <c-object>
    [ LookupPrivilegeValue win32-error=0/f ] keep ;

: make-token-privileges ( name ? -- obj )
    "TOKEN_PRIVILEGES" <c-object>
    1 [ over set-TOKEN_PRIVILEGES-PrivilegeCount ] keep
    "LUID_AND_ATTRIBUTES" malloc-array
    dup [ free ] t add-destructor over set-TOKEN_PRIVILEGES-Privileges

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
        dup length f f AdjustTokenPrivileges win32-error=0/f
    ] with-process-token ;

: with-privileges ( seq quot -- )
    over [ [ t set-privilege ] each ] curry compose
    swap [ [ f set-privilege ] each ] curry [ ] cleanup ;

: mmap-open ( path access-mode create-mode flProtect access length -- handle handle address )
    drop
    { "SeCreateGlobalPrivilege" "SeLockMemoryPrivilege" } [
        >r >r open-file dup f r> 0 0 f
        CreateFileMapping [ win32-error=0/f ] keep
        dup [ CloseHandle drop ] f add-destructor
        dup
        r> 0 0 0 MapViewOfFile [ win32-error=0/f ] keep
        dup [ CloseHandle drop ] f add-destructor
    ] with-privileges ;
    
M: windows-io <mapped-file> ( path length -- mmap )
    [
        [
            >r
            GENERIC_WRITE GENERIC_READ bitor
            OPEN_ALWAYS
            PAGE_READWRITE SEC_COMMIT bitor
            FILE_MAP_ALL_ACCESS r> mmap-open
        ] keep
    -roll -rot 2array \ mapped-file construct-boa
    ] with-destructors ;

M: windows-io close-mapped-file ( mapped-file -- )
    [
        dup mapped-file-handle [
            [ CloseHandle drop ] t add-destructor
        ] each
        mapped-file-address UnmapViewOfFile win32-error=0/f
    ] with-destructors ;
