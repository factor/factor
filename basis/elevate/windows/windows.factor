USING: io.launcher elevate ;
IN: elevate.windows


<PRIVATE
! TODO
M:: windows elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [
        <process> command >>command
    ] [
        ! hwnd lpOperation
        f "runas"
        command dup string? [ " " split ] when
        ! lpFile lpParameters lpDirectory nShowCmd
        [ first ] [ rest ] bi f win-console? 1 0 ?
        ! call shell function
        ShellExecuteW :> retval retval n>win32-error-check
        retval replace? [ exit ] [ ] if
    ] if ;

! no-op (not possible to lower)
M: windows lowered
PRIVATE>