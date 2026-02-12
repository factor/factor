USING: accessors io io.encodings.ascii io.launcher kernel make
namespaces sequences system tools.test ;
IN: compiler.tests.callback-error

SYMBOL: callback-error-source

: run-vm-with-script ( -- lines )
    <process>
        [ vm-path , callback-error-source get "-e=" prepend , ] { } make >>command
        +closed+ >>stdin
        +stdout+ >>stderr
    ascii <process-reader> stream-lines ;

{ } [
    " USING: alien alien.c-types alien.syntax kernel ;
    IN: scratchpad

    : callback-death ( -- callback )
        void { } cdecl [ \"Error!\" throw ] alien-callback ;

    : callback-invoke ( callback -- )
        void { } cdecl alien-indirect ;

    callback-death callback-invoke"
    callback-error-source set-global
] unit-test

! Callback error from initial thread
{ t } [  run-vm-with-script "\"Error!\"" swap member? ] unit-test

{ } [
    "USING: alien alien.c-types alien.syntax kernel threads ;
    IN: scratchpad

    : callback-death ( -- callback )
        void { } cdecl [ \"Error!\" throw ] alien-callback ;

    : callback-invoke ( callback -- )
        void { } cdecl alien-indirect ;

    [ callback-death callback-invoke ] in-thread
    stop"
    callback-error-source set-global
] unit-test

! Callback error from another thread
{ t } [ run-vm-with-script "\"Error!\"" swap member? ] unit-test
