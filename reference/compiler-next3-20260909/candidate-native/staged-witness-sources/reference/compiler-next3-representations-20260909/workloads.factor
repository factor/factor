! Definitions only. The selected kernel is compiled and timed by the caller.
USING: arrays kernel kernel.private math math.private namespaces sequences
sequences.generalizations ;
IN: compiler-next3-representation-workload

: representation-loop-values ( n -- values )
    { fixnum } declare
    0.0 swap [ 1.0 float+ ] times
    dup dup dup dup dup dup dup dup
    dup dup dup dup dup dup dup dup
    dup dup dup dup dup dup dup dup
    dup dup dup dup dup dup dup
    32 narray ;

SYMBOL: selected-representation-kernel
\ representation-loop-values selected-representation-kernel set-global

: representation-loop-work ( -- )
    10000 selected-representation-kernel get execute( n -- values )
    dup length 32 assert=
    [ 10000.0 = ] all? t assert= ;
