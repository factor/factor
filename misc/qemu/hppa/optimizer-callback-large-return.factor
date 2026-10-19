! Execute from an ordinary image after normal cpu.hppa reload.
USING: accessors alien alien.c-types alien.syntax classes.struct compiler
compiler.test destructors io kernel namespaces sequences tools.test words ;
IN: cpu.hppa.callback-large-return
STRUCT: callback-double-pair { first double } { second double } ;
: pair-callback ( -- callback )
    callback-double-pair { double double } cdecl [
        callback-double-pair <struct> swap >>second swap >>first
    ] alien-callback ;
: call-pair ( a b callback -- pair )
    callback-double-pair { double double } cdecl alien-indirect ;
{ pair-callback call-pair } compile
{ t } [ { pair-callback call-pair } [ word-optimized? ] all? ] unit-test
{ 1.0 2.0 } [
    1.0 2.0 pair-callback [ call-pair [ first>> ] [ second>> ] bi ] with-callback
] unit-test
{ -42.5 10.25 } [
    -42.5 10.25 pair-callback [ call-pair [ first>> ] [ second>> ] bi ] with-callback
] unit-test
test-failures get empty? t assert=
"Optimized HPPA large-structure callback return passed" print
