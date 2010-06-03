USING: alien alien.c-types kernel math ;
IN: tools.deploy.test.9

: callback-test ( -- callback )
    int { int } cdecl [ 1 + ] alien-callback ;

: indirect-test ( -- )
    10 callback-test int { int } cdecl alien-indirect 11 assert= ;

MAIN: indirect-test
