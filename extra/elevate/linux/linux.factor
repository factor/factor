USING: accessors arrays elevate elevate.private elevate.unix
elevate.unix.private environment io.launcher kernel locals
sequences system ui ;
IN: elevate.linux

<PRIVATE
M:: linux elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [
        <process> command >>command 1array ! we are already root: just give a process
    ] [
        posix-graphical? ui-running? or "DISPLAY" os-env and [
            command { "gksudo" "kdesudo" "pkexec" "sudo" } [
                prepend-command
            ] with map :> command-list

            command-list [
                replace? [ posix-replace-process ] [
                    ! need to fix race condition
                    <process> swap >>command t >>detached run-process
                ] if
            ] map [
                [ failed-process? ] all? [
                    command command-list elevated-failed
                ] [ ] if
            ] keep
        ] [
            command replace? posix-elevated ! sudo only
        ] if
    ] if ;

M: linux lowered
    posix-lowered ;

PRIVATE>
