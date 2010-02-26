! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix unix.utmpx unix.ffi.bsd.netbsd accessors
system kernel combinators ;
IN: unix.utmpx.netbsd

TUPLE: netbsd-utmpx-record < utmpx-record
termination exit sockaddr ;

M: netbsd new-utmpx-record ( -- utmpx-record )
    netbsd-utmpx-record new ;

M: netbsd utmpx>utmpx-record ( utmpx -- record )
    [ new-utmpx-record ] dip
    [
        ut_exit>>
        [ e_termination>> >>termination ]
        [ e_exit>> >>exit ] bi
    ]
    [ ut_ss>> >>sockaddr ] bi ;
