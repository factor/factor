USING: arrays command-line fry io.launcher kernel math namespaces
sequences system unix.ffi ;
IN: elevate

: apple-script-elevate ( x x -- ) 2drop ;

HOOK: elevate os ( win-console? posix-graphical? -- )

M: windows elevate 2drop ;

M: macosx elevate
    [   ! graphical (through applescript)
        t apple-script-elevate
    ] [
        f linux os [ elevate ] with-variable
    ] if ;

M: linux elevate
    getuid zero? [
        2drop ! we are already root: do nothing
    ] [
        ! graphical on linuxes
        nip [ { "gksudo" "kdesudo" } ] [ { } ] if
        "sudo" suffix (command-line) '[ 1array _ append ] map
        [
            run-process drop
        ] each
    ] if ;

HOOK: lower os ( relaunch? -- )
