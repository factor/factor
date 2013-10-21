! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data system kernel unix math sequences
io.backend.unix io.ports libc specialized-arrays accessors unix.ffi ;
QUALIFIED: io.pipes
SPECIALIZED-ARRAY: int
IN: io.pipes.unix

M: unix io.pipes:(pipe) ( -- pair )
    2 int <c-array>
    [ pipe io-error ]
    [ first2 [ <fd> init-fd ] bi@ io.pipes:pipe boa ] bi ;
