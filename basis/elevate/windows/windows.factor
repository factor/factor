USING: accessors alien alien.c-types elevate io.launcher kernel
locals math sequences splitting strings system windows.errors
windows.shell32 ;
IN: elevate.windows

<PRIVATE
! TODO
M: windows already-root?
    f ;

M:: windows elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [
        <process> command >>command
    ] [
        ! hwnd lpOperation
        f "runas"
        command dup string? [ " " split ] when
        ! lpFile lpParameters lpDirectory nShowCmd
        [ first ] [ rest ] bi " " join f win-console? >c-bool
        ! call shell function
        ShellExecuteW alien-address :> retval retval 32 <= [ retval n>win32-error-check ] [ ] if
        retval replace? [ exit ] [ ] if
    ] if ;

! no-op (not possible to lower)
M: windows lowered ;
PRIVATE>
