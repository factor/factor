! Copyright (C) 2011 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.strings destructors io.encodings.utf8 kernel libc
sequences macros quotations words compiler.units fry
alien.data alien.libraries ;
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

: has-readline? ( -- ? )
    "readline" dup load-library dlsym-raw >boolean ;

: set-completion ( quot -- )
    [
       '[
            [ @ [ utf8 malloc-string ] [ f ] if* ]
            readline.ffi:rl_compentry_func_t
        ] ( -- alien ) define-temp
    ] with-compilation-unit execute( -- alien )
    readline.ffi:set-rl_completion_entry_function ;
