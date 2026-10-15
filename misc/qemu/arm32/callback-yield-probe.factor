USING: alien alien.c-types alien.syntax arrays compiler compiler.units io kernel math memory sequences system threads threads.private words ;
IN: arm32-callback-yield-probe
: invoke ( ptr -- ) void { } cdecl alien-indirect ;
: cb ( -- callback ) void { } cdecl [ [ ] in-thread yield ] alien-callback ;
: cb-gc ( -- callback ) void { } cdecl [ [ gc ] in-thread yield gc ] alien-callback ;
: check ( -- )
    cb [ invoke ] with-callback
    cb-gc [ invoke ] with-callback ;
: main ( -- )
    \ check 1array compile
    \ check word-optimized? [ ] [ 4 exit ] if
    20 [ check ] times
    "ARM32 optimized callback yield/parked-context GC PASS" print ;
MAIN: main
