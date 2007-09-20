USING: alien alien.c-types destructors io.windows libc
io.nonblocking io.streams.duplex windows.types math
windows.kernel32 windows namespaces io.launcher kernel ;
IN: io.windows.launcher

! From MSDN: "Handles in PROCESS_INFORMATION must be closed with CloseHandle when they are no longer needed."

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

: default-CreateProcess-args ( lpCommandLine -- obj )
    0
    0
    "STARTUPINFO" <c-object>
    "STARTUPINFO" heap-size over set-STARTUPINFO-cb
    "PROCESS_INFORMATION" <c-object>
    {
        set-CreateProcess-args-lpCommandLine
        set-CreateProcess-args-bInheritHandles
        set-CreateProcess-args-dwCreateFlags
        set-CreateProcess-args-lpStartupInfo
        set-CreateProcess-args-lpProcessInformation
    } \ CreateProcess-args construct ;

: call-CreateProcess ( CreateProcess-args -- )
    {
        CreateProcess-args-lpApplicationName
        CreateProcess-args-lpCommandLine
        CreateProcess-args-lpProcessAttributes
        CreateProcess-args-lpThreadAttributes
        CreateProcess-args-bInheritHandles
        CreateProcess-args-dwCreateFlags
        CreateProcess-args-lpEnvironment
        CreateProcess-args-lpCurrentDirectory
        CreateProcess-args-lpStartupInfo
        CreateProcess-args-lpProcessInformation
    } get-slots CreateProcess win32-error=0/f ;

M: windows-io run-process ( string -- )
    default-CreateProcess-args
    call-CreateProcess ;

M: windows-io run-detached ( string -- )
    default-CreateProcess-args
    DETACHED_PROCESS over set-CreateProcess-args-dwCreateFlags
    call-CreateProcess ;

: default-security-attributes ( -- obj )
    "SECURITY_ATTRIBUTES" <c-object>
    "SECURITY_ATTRIBUTES" heap-size over set-SECURITY_ATTRIBUTES-nLength ;

: security-attributes-inherit ( -- obj )
    default-security-attributes
    TRUE over set-SECURITY_ATTRIBUTES-bInheritHandle ;

: set-inherit ( handle ? -- )
    >r HANDLE_FLAG_INHERIT r> >BOOLEAN SetHandleInformation win32-error=0/f ;

! http://msdn2.microsoft.com/en-us/library/ms682499.aspx

TUPLE: pipe hRead hWrite ;

C: <pipe> pipe

: factor-pipe-name
    "\\\\.\\pipe\\Factor" ;

: create-named-pipe ( str -- handle )
    PIPE_ACCESS_DUPLEX FILE_FLAG_OVERLAPPED bitor
    PIPE_TYPE_BYTE PIPE_READMODE_BYTE PIPE_NOWAIT bitor bitor
    PIPE_UNLIMITED_INSTANCES
    default-buffer-size
    default-buffer-size
    0
    security-attributes-inherit
    CreateNamedPipe dup invalid-handle? ;

: ERROR_PIPE_CONNECT 535 ; inline

M: windows-nt-io <process-stream> ( command -- stream )
    [
        default-CreateProcess-args
        TRUE over set-CreateProcess-args-bInheritHandles

        ! over set-CreateProcess-args-stdin-pipe

        dup CreateProcess-args-lpStartupInfo
        STARTF_USESTDHANDLES over set-STARTUPINFO-dwFlags

        factor-pipe-name create-named-pipe
        dup t set-inherit
        [ add-completion ] keep
 
        ! CreateFile
        ! factor-pipe-name open-pipe-r/w
        factor-pipe-name GENERIC_READ GENERIC_WRITE bitor 0 f OPEN_EXISTING FILE_FLAG_OVERLAPPED f CreateFile dup invalid-handle? dup [ CloseHandle drop ] f add-destructor
        dup add-completion

        swap (make-overlapped) ConnectNamedPipe zero? [
            GetLastError ERROR_PIPE_CONNECT = [
                win32-error-string throw
            ] unless
        ] when

        dup t set-inherit

        ! ERROR_PIPE_CONNECTED
        [ pick set-CreateProcess-args-stdin-pipe ] keep
        [ over set-STARTUPINFO-hStdOutput ] keep
        [ over set-STARTUPINFO-hStdInput ] keep
        swap set-STARTUPINFO-hStdError
! 
        [ call-CreateProcess ] keep
        [ CreateProcess-args-stdin-pipe f <win32-file> dup handle>duplex-stream ] keep
        drop ! TODO: close handles instead of drop
    ] with-destructors ;

: create-pipe ( -- pipe )
    "HANDLE" <c-object>
    "HANDLE" <c-object>
    [
        security-attributes-inherit
        0
        CreatePipe win32-error=0/f
    ] 2keep
    [ *void* dup [ CloseHandle ] f add-destructor ] 2apply <pipe> ;

M: windows-ce-io <process-stream>
    [
        default-CreateProcess-args
        TRUE over set-CreateProcess-args-bInheritHandles

        create-pipe  ! for child's STDOUT
        dup pipe-hRead f set-inherit
        over set-CreateProcess-args-stdout-pipe

        create-pipe  ! for child's STDIN
        dup pipe-hWrite f set-inherit
        over set-CreateProcess-args-stdin-pipe

        dup CreateProcess-args-lpStartupInfo
        STARTF_USESTDHANDLES over set-STARTUPINFO-dwFlags

        over CreateProcess-args-stdout-pipe
            pipe-hWrite over set-STARTUPINFO-hStdOutput
        over CreateProcess-args-stdout-pipe
            pipe-hWrite over set-STARTUPINFO-hStdError
        over CreateProcess-args-stdin-pipe
            pipe-hRead swap set-STARTUPINFO-hStdInput

        [ call-CreateProcess ] keep
        [ CreateProcess-args-stdin-pipe pipe-hRead f <win32-file> <reader> ] keep
        [ CreateProcess-args-stdout-pipe pipe-hWrite f <win32-file> <writer> <duplex-stream> ] keep
        drop ! TODO: close handles instead of drop
    ] with-destructors ;

