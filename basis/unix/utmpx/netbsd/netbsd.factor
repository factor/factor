! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax unix.utmpx unix.bsd.netbsd accessors
unix.utmpx system kernel unix combinators ;
IN: unix.utmpx.netbsd

TUPLE: netbsd-utmpx-record < utmpx-record termination exit
sockaddr ;
    
M: netbsd new-utmpx-record ( -- utmpx-record )
    netbsd-utmpx-record new ; 
    
M: netbsd utmpx>utmpx-record ( utmpx -- record )
    [ new-utmpx-record ] keep
    {
        [
            utmpx-ut_exit
            [ exit_struct-e_termination >>termination ]
            [ exit_struct-e_exit >>exit ] bi
        ]
        [ utmpx-ut_ss >>sockaddr ]
    } cleave ;
