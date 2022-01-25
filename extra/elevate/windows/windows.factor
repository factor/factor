USING: accessors alien alien.c-types elevate io.launcher kernel
locals math sequences splitting strings system windows.errors
windows.kernel32 windows.shell32 windows.user32 ;
IN: elevate.windows

<PRIVATE
! TODO
M: windows already-root?
    ! https://msdn.microsoft.com/en-us/library/windows/desktop/aa379296(v=vs.85).aspx
    ! https://msdn.microsoft.com/en-us/library/windows/desktop/aa446671%28v=vs.85%29.aspx
    ! https://msdn.microsoft.com/en-us/library/windows/desktop/ms683182(v=vs.85).aspx
    f ;

M:: windows elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [
        <process> command >>command
    ] [
        ! hwnd lpOperation
        f "runas"
        command dup string? [ " " split ] when
        ! lpFile lpParameters lpDirectory (enum)nShowCmd
        [ first ] [ rest ] bi " " join f SW_SHOW
        ! call shell function with questionable return pointer handling (should use WaitForSingleObject but it hangs)
        ShellExecuteW alien-address :> retval retval 32 <= [ retval n>win32-error-check ] [ ] if
        replace? [ exit ] [ ] if
    ] if ;

! no-op (not possible to lower)
M: windows lowered ;
PRIVATE>
