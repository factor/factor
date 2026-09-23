! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays continuations kernel
kernel.private libc math memory sequences tools.memory
tools.profiler.sampling tools.profiler.sampling.private tools.test
unix.process ;
IN: compiler.tests.safepoints

: nursery-filler-size ( -- n ) data-room nursery>> size>> 96 - ;

: with-sampling ( quot -- )
    1 set-profiling [ 0 set-profiling ] finally ; inline

: sample-callstacks ( -- callstacks )
    get-samples [ sample-callstack ] map ;

: sample-in-loop ( holder n -- array )
    { array fixnum } declare
    minor-gc 1 2 3 3array swap (byte-array) drop
    [ 0 rot set-nth ] keep
    3 [ SIGALRM raise drop ] times ;

{ t t } [
    1 f <array> dup nursery-filler-size
    [ sample-in-loop ] with-sampling
    swap first eq?
    \ sample-in-loop sample-callstacks [ member-eq? ] with any?
] unit-test

: sample-at-minor-gc-entry ( holder n -- array array )
    { array fixnum } declare
    minor-gc 1 2 3 3array swap (byte-array) drop
    [ 0 rot set-nth ] keep
    SIGALRM raise drop
    4 5 6 3array ;

{ t { 4 5 6 } t } [
    1 f <array> dup nursery-filler-size
    [ sample-at-minor-gc-entry ] with-sampling
    [ swap first eq? ] dip
    sample-callstacks
    [ { minor-gc sample-at-minor-gc-entry } subseq-of? ] any?
] unit-test
