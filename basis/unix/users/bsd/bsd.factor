! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators accessors kernel unix.users
system ;
IN: unix.users.bsd
QUALIFIED: unix

TUPLE: bsd-passwd < passwd change class expire fields ;

M: bsd new-passwd ( -- bsd-passwd ) bsd-passwd new ;

M: bsd passwd>new-passwd ( passwd -- bsd-passwd )
    [ call-next-method ] keep
    {
        [ pw_change>> >>change ]
        [ pw_class>> >>class ]
        [ pw_shell>> >>shell ]
        [ pw_expire>> >>expire ]
        [ pw_fields>> >>fields ]
    } cleave ;
