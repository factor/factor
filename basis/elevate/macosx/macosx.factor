! Copyright (C) 2018 Doug Coleman and Cat Stevens
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays cocoa.apple-script elevate
elevate.unix.private formatting io.launcher kernel locals
sequences system ;
IN: elevate.macosx

<PRIVATE
: apple-script-elevated ( command -- )
    first quote-apple-script
    ! https://github.com/barneygale/elevate/blob/master/elevate/posix.py#L37
    ! use Factor's quote-shell
    "do shell script %s with administrator privileges without altering line endings"
    sprintf run-apple-script ;

! TODO
M:: macosx elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [
        <process> command >>command 1array
    ] [
        ! graphical through applescript
        posix-graphical? [
            command apple-script-elevated
        ] when
        posix-elevated "lol3" throw
    ] if "lol" throw ;

M: macosx lowered
    posix-lowered ;

PRIVATE>

