USING: accessors arrays assocs command-line environment
formatting fry io.launcher kernel ui locals math namespaces
sequences splitting strings system unix.ffi unix.process ;
IN: elevate

<PRIVATE
ERROR: elevated-failed command { strategies array } ;
ERROR: lowered-failed ;

CONSTANT: apple-script-charmap H{
    { "\n" "\\n" }
    { "\r" "\\r" }
    { "\t" "\\t" }
    { "\"" "\\\"" }
    { "\\" "\\\\" }
}

: quote-apple-script ( str -- str' )
    [ 1string [ apple-script-charmap at ] [ ] bi or ] { } map-as
    "" join "\"" dup surround ;

: run-apple-script ( str -- ) drop ;

: apple-script-elevated ( command -- )
    quote-apple-script
    "do shell script %s with administrator privileges without altering line endings"
    sprintf run-apple-script ;

: posix-replace-process ( command-list -- code )
  [ first ] [ rest ] bi exec-with-path ;

: already-root? ( -- ? )
    getuid geteuid [ zero? ] bi@ or ;

GENERIC: glue-command ( prefix command -- glued )

M: array glue-command
    swap prefix ;

M: string glue-command
    " " glue ;

GENERIC: failed-process? ( process -- ? )
M: f failed-process? not ;
M: fixnum failed-process? -1 = ;
M: process failed-process? status>> zero? not ;

: posix-lowered ( -- )
    getgid setgid failed-process? [ lowered-failed ] [ ] if
    getuid setuid failed-process? [ lowered-failed ] [ ] if ;

PRIVATE>

HOOK: elevated os ( command replace? win-console? posix-graphical? -- process )

! TODO
M: windows elevated
    3drop run-process ;

! TODO
M:: macosx elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [ <process> command >>command 1array ] [
        posix-graphical? [ ! graphical (through applescript)
            command apple-script-elevated
        ] when
        command replace? win-console? posix-graphical?
        linux os [ elevated ] with-variable
    ] if ;

M:: linux elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [
        <process> command >>command 1array ! we are already root: just give a process
    ] [
        ! graphical handled
        posix-graphical? ui-running? or "DISPLAY" os-env and
        { "gksudo" "kdesudo" "sudo" } { "sudo" } ?

        command '[ _ glue-command ] map :> command-list command-list [
            replace? [
                " " split posix-replace-process
            ] [ run-process ] if
        ] map
        ! if they all failed, then it failed, but if one passed, that's normal (success)
        [ [ failed-process? ] all? [ command command-list elevated-failed ] [ ] if ] keep
    ] if ;

: elevate ( win-console? posix-graphical? -- ) [ (command-line) t ] 2dip elevated drop ;

HOOK: lowered os ( -- )

! https://wiki.sei.cmu.edu/confluence/display/c/POS36-C.+Observe+correct+revocation+order+while+relinquishing+privileges
! group ID must be lowered before user ID otherwise program may re-gain root!
M: linux lowered
    posix-lowered ;

M: macosx lowered
    posix-lowered ;

M: windows lowered ;