! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators accessors kernel unix unix.users
system ;
IN: unix.users.bsd

TUPLE: bsd-passwd < passwd change class expire fields ;

M: bsd new-passwd ( -- bsd-passwd ) bsd-passwd new ;

M: bsd passwd>new-passwd ( passwd -- bsd-passwd )
    [ call-next-method ] keep
    {
        [ passwd-pw_change >>change ]
        [ passwd-pw_class >>class ]
        [ passwd-pw_shell >>shell ]
        [ passwd-pw_expire >>expire ]
        [ passwd-pw_fields >>fields ]
    } cleave ;
