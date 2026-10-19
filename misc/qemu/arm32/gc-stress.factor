! Run after loading the ARM32 optimizing compiler, on either native VM.
! Use -young=1 to force collections even when saved heap settings differ.
! Retained arrays force nursery collections while the map builder has live roots.
USING: arrays compiler compiler.units io kernel locals math sequences words ;
IN: arm32.gc-stress

:: retained-arrays ( anchor -- n )
    200000 <iota> [ dup 2array ] map :> arrays
    anchor first arrays last first + ;

\ retained-arrays 1array compile
\ retained-arrays word-optimized?
[ ] [ "ARM32 GC stress word was not optimized" throw ] if
3 [
    7 11 2array retained-arrays 200006 =
    [ ] [ "ARM32 optimized GC stress failed" throw ] if
] times
"ARM32 optimized retained-array GC stress passed" print
