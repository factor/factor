USING: accessors compiler compiler.units tools.test math parser
kernel sequences sequences.private classes.mixin generic
definitions arrays words assocs eval strings ;
IN: compiler.tests.redefine1

GENERIC: method-redefine-generic-1 ( a -- b )

M: integer method-redefine-generic-1 3 + ;

: method-redefine-test-1 ( -- b ) 3 method-redefine-generic-1 ;

{ 6 } [ method-redefine-test-1 ] unit-test

{ } [ "IN: compiler.tests.redefine1 USE: math M: fixnum method-redefine-generic-1 4 + ;" eval( -- ) ] unit-test

{ 7 } [ method-redefine-test-1 ] unit-test

{ } [ [ fixnum \ method-redefine-generic-1 lookup-method forget ] with-compilation-unit ] unit-test

{ 6 } [ method-redefine-test-1 ] unit-test

GENERIC: method-redefine-generic-2 ( a -- b )

M: integer method-redefine-generic-2 3 + ;

: method-redefine-test-2 ( -- b ) 3 method-redefine-generic-2 ;

{ 6 } [ method-redefine-test-2 ] unit-test

{ } [ "IN: compiler.tests.redefine1 USE: kernel USE: math M: fixnum method-redefine-generic-2 4 + ; USE: strings M: string method-redefine-generic-2 drop f ;" eval( -- ) ] unit-test

{ 7 } [ method-redefine-test-2 ] unit-test

{ } [
    [
        fixnum string [ \ method-redefine-generic-2 lookup-method forget ] bi@
    ] with-compilation-unit
] unit-test
