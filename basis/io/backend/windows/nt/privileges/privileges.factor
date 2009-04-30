USING: alien alien.c-types alien.syntax arrays continuations
destructors generic io.mmap io.ports io.backend.windows io.files.windows
kernel libc math math.bitwise namespaces quotations sequences windows
windows.advapi32 windows.kernel32 io.backend system accessors
io.backend.windows.privileges windows.errors ;
IN: io.backend.windows.nt.privileges

TYPEDEF: TOKEN_PRIVILEGES* PTOKEN_PRIVILEGES

! Security tokens
!  http://msdn.microsoft.com/msdnmag/issues/05/03/TokenPrivileges/

: (open-process-token) ( handle -- handle )
    { TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY } flags "PHANDLE" <c-object>
    [ OpenProcessToken win32-error=0/f ] keep *void* ;

: open-process-token ( -- handle )
    #! remember to CloseHandle
    GetCurrentProcess (open-process-token) ;

: with-process-token ( quot -- )
    #! quot: ( token-handle -- token-handle )
    [ open-process-token ] dip
    [ keep ] curry
    [ CloseHandle drop ] [ ] cleanup ; inline

: lookup-privilege ( string -- luid )
    [ f ] dip "LUID" <c-object>
    [ LookupPrivilegeValue win32-error=0/f ] keep ;

: make-token-privileges ( name ? -- obj )
    "TOKEN_PRIVILEGES" <c-object>
    1 [ over set-TOKEN_PRIVILEGES-PrivilegeCount ] keep
    "LUID_AND_ATTRIBUTES" malloc-array &free
    over set-TOKEN_PRIVILEGES-Privileges

    swap [
        SE_PRIVILEGE_ENABLED over TOKEN_PRIVILEGES-Privileges
        set-LUID_AND_ATTRIBUTES-Attributes
    ] when

    [ lookup-privilege ] dip
    [
        TOKEN_PRIVILEGES-Privileges
        set-LUID_AND_ATTRIBUTES-Luid
    ] keep ;

M: winnt set-privilege ( name ? -- )
    [
        -rot 0 -rot make-token-privileges
        dup length f f AdjustTokenPrivileges win32-error=0/f
    ] with-process-token ;
