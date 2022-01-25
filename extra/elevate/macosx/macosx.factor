USING: accessors arrays cocoa.apple-script elevate
elevate.unix.private formatting io.launcher kernel locals
sequences system ;
IN: elevate.macosx

<PRIVATE
: apple-script-elevated ( command -- )
    first quote-apple-script
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
        posix-elevated  "lol3" throw
    ] if "lol" throw ;

M: macosx lowered
    posix-lowered ;

PRIVATE>

