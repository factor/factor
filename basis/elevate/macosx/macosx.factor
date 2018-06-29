USING: cocoa.apple-script elevate elevate.unix ;
IN: elevate.macosx

<PRIVATE
: apple-script-elevated ( command -- )
    quote-apple-script
    "do shell script %s with administrator privileges without altering line endings"
    sprintf run-apple-script ;

! TODO
M:: macosx elevated ( command replace? win-console? posix-graphical? -- process )
    already-root? [ <process> command >>command 1array ] [
        posix-graphical? [ ! graphical through applescript
            command apple-script-elevated
        ] when
        posix-elevated
    ] if ;

M: macosx lowered
    posix-lowered ;

PRIVATE>

