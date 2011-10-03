USING: accessors io io.encodings.ascii io.launcher kernel make
sequences system tools.test ;
IN: compiler.tests.callback-error

: run-vm-with-script ( string -- lines )
    [ <process> ] dip
        [ vm , , ] { } make >>command
        +closed+ >>stdin
        +stdout+ >>stderr
    ascii <process-reader> stream-lines ;

! Callback error from initial thread
[ t ] [
    """-e=USING: alien alien.c-types alien.syntax kernel ;
    IN: scratchpad
    
    : callback-death ( -- callback )
        void { } cdecl [ "Error!" throw ] alien-callback ;
    
    : callback-invoke ( callback -- )
        void { } cdecl alien-indirect ;
    
    callback-death callback-invoke"""
    run-vm-with-script
    "\"Error!\"" swap member?
] unit-test

! Callback error from another thread
[ t ] [
    """-e=USING: alien alien.c-types alien.syntax kernel threads ;
    IN: scratchpad
    
    : callback-death ( -- callback )
        void { } cdecl [ "Error!" throw ] alien-callback ;
    
    : callback-invoke ( callback -- )
        void { } cdecl alien-indirect ;
    
    [ callback-death callback-invoke ] in-thread
    stop"""
    run-vm-with-script
    "\"Error!\"" swap member?
] unit-test
