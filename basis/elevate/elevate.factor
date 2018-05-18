USING: arrays command-line fry io.launcher kernel math namespaces
sequences system unix.ffi ;
IN: elevate

: apple-script-elevate ( command -- ) 2drop ;

GENERIC: glue-command ( prefix command -- glued )

M: array glue-command
    swap prefix ;

M: string glue-command
    " " glue ;

ERROR: elevated-failed path ;

HOOK: elevated os ( command win-console? posix-graphical? -- process )

M: windows elevated
    2drop run-process ;

M: macosx elevated
    nip [ ! graphical (through applescript)
        apple-script-elevate
    ] [
        f f linux os [ elevated ] with-variable
    ] if ;

M: linux elevated
    nip getuid zero? [
        drop ! we are already root: do nothing
    ] [
        { "gksudo" "kdesudo" "sudo" } { "sudo" } ? ! graphical handled
        swap '[ _ glue-command ] map
        [ " " split [ first utf8 string>alien ] [ rest ] execvp ] map
        [ -1 = ] all? elevated-failed
    ] if ;

: elevate ( option? -- ) (command-line) elevated ;

HOOK: lowered os ( relaunch? -- )

