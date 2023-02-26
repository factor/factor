USING: alien alien.syntax eval math tools.test ;
QUALIFIED: alien.c-types
IN: compiler.tests.redefine24

TYPEDEF: alien.c-types:int type-1

TYPEDEF: alien.c-types:int type-3

: callback ( -- ptr )
    type-3 { type-1 type-1 } cdecl [ + >integer ] alien-callback ;

TYPEDEF: alien.c-types:float type-2

: indirect ( x y ptr -- z )
    type-3 { type-2 type-2 } cdecl alien-indirect ;

{ } [
    "USING: alien.c-types alien.syntax ;
    IN: compiler.tests.redefine24 TYPEDEF: int type-2" eval( -- )
] unit-test

{ 3 } [ 1 2 callback indirect ] unit-test

{ } [
    "USING: alien.c-types alien.syntax ;
    IN: compiler.tests.redefine24
    TYPEDEF: float type-1
    TYPEDEF: float type-2" eval( -- )
] unit-test

{ 3 } [ 1.0 2.0 callback indirect ] unit-test

{ } [
    "USING: alien.c-types alien.syntax ;
    IN: compiler.tests.redefine24
    TYPEDEF: float type-3" eval( -- )
] unit-test

{ 3.0 } [ 1.0 2.0 callback indirect ] unit-test
