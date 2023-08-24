! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data io.backend.unix io.pipes kernel
libc sequences specialized-arrays system unix.ffi ;
SPECIALIZED-ARRAY: int
IN: io.pipes.unix

M: unix (pipe)
    2 int <c-array>
    [ unix.ffi:pipe io-error ]
    [ first2 [ <fd> init-fd ] bi@ io.pipes:pipe boa ] bi ;
