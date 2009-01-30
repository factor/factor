! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system kernel unix math sequences
io.backend.unix io.ports specialized-arrays.int accessors ;
IN: io.pipes.unix
QUALIFIED: io.pipes

M: unix io.pipes:(pipe) ( -- pair )
    2 <int-array>
    [ underlying>> pipe io-error ]
    [ first2 [ <fd> init-fd ] bi@ io.pipes:pipe boa ] bi ;
