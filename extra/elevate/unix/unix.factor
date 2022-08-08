USING: arrays elevate elevate.private io.launcher kernel locals
math sequences splitting strings system unix.ffi unix.process prettyprint ;
IN: elevate.unix

<PRIVATE
! https://wiki.sei.cmu.edu/confluence/x/p9YxBQ
! group ID must be lowered before user ID otherwise program may re-gain root!
: posix-lowered ( -- )
    getgid setgid failed-process? [ lowered-failed ] [ ] if
    getuid setuid failed-process? [ lowered-failed ] [ ] if ;

GENERIC: posix-replace-process ( command-list -- code )
! naive split breaks with spaces inside quotes in shell commands
M: string posix-replace-process
    " " split posix-replace-process ;
M: array posix-replace-process
    [ first ] [ rest " " prefix ] bi exec-with-path ;

! if either the real or effective user IDs are 0, we are already elevated
M: unix already-root?
    getuid geteuid [ zero? ] bi@ or ;

:: posix-elevated ( command replace? -- process )
    command "sudo" prepend-command
    replace? [ posix-replace-process ] [ run-process ] if
    dup failed-process? [ drop command { "sudo" } elevated-failed ] [ ] if ;

M: unix elevated
    2drop posix-elevated ;

PRIVATE>
