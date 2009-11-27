USING: alien alien.c-types alien.data alien.syntax arrays continuations
destructors generic io.mmap io.ports io.backend.windows io.files.windows
kernel libc locals math math.bitwise namespaces quotations sequences windows
windows.advapi32 windows.kernel32 windows.types io.backend system accessors
io.backend.windows.privileges classes.struct windows.errors ;
IN: io.backend.windows.nt.privileges

TYPEDEF: TOKEN_PRIVILEGES* PTOKEN_PRIVILEGES

! Security tokens
!  http://msdn.microsoft.com/msdnmag/issues/05/03/TokenPrivileges/

: (open-process-token) ( handle -- handle )
    { TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY } flags PHANDLE <c-object>
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
    [ f ] dip LUID <struct>
    [ LookupPrivilegeValue win32-error=0/f ] keep ;

:: make-token-privileges ( name enabled? -- obj )
    TOKEN_PRIVILEGES <struct>
        1 >>PrivilegeCount
        LUID_AND_ATTRIBUTES malloc-struct &free
            enabled? [ SE_PRIVILEGE_ENABLED >>Attributes ] when
            name lookup-privilege >>Luid
        >>Privileges ;

M: winnt set-privilege ( name ? -- )
    [
        -rot 0 -rot make-token-privileges
        dup byte-length f f AdjustTokenPrivileges win32-error=0/f
    ] with-process-token ;
