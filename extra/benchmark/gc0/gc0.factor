! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays kernel math ;
IN: benchmark.gc0

: allocate ( -- obj ) 10 f <array> ;

: gc0-benchmark ( -- ) f 60000000 [ allocate nip ] times drop ;

MAIN: gc0-benchmark
