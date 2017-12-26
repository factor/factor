! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.complex.functor
classes.struct kernel math quotations ;
FROM: alien.c-types => float double ;
IN: alien.complex

COMPLEX-TYPE: float complex-float
COMPLEX-TYPE: double complex-double

<<
! This overrides the fact that small structures are never returned
! in registers on Linux running on 32-bit x86.
\ complex-float lookup-c-type t >>return-in-registers? drop
>>
