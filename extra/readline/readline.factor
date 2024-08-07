! Copyright (C) 2011 Erik Charlebois.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.data alien.libraries alien.strings compiler.units
continuations destructors io.backend io.encodings.utf8 kernel
libc sequences words ;
QUALIFIED: readline.ffi
IN: readline

: readline ( prompt -- str )
    [
        readline.ffi:readline [
            |free utf8 alien>string [
                [ readline.ffi:add_history ] unless-empty
            ] keep
        ] [ f ] if*
    ] with-destructors ;

: current-line ( -- str )
    readline.ffi:rl_line_buffer ;

: completion-line ( -- str )
    current-line readline.ffi:rl_point head ;

: has-readline? ( -- ? )
    "readline" dup library-dll dlsym >boolean ;

: set-completion ( quot -- )
    [
        '[
            [ @ [ utf8 malloc-string ] [ f ] if* ]
            readline.ffi:rl_compentry_func_t
        ] ( -- alien ) define-temp
    ] with-compilation-unit execute( -- alien )
    readline.ffi:set-rl_completion_entry_function ;

:: with-history ( path quot -- )
    path normalize-path :> history-path
    history-path readline.ffi:read_history io-error
    quot [ history-path readline.ffi:write_history io-error ] finally ; inline
