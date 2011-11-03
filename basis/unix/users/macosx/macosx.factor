! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators accessors kernel unix.users
system ;
IN: unix.users.macosx

TUPLE: macosx-passwd < passwd change class expire fields ;

M: macosx new-passwd ( -- macosx-passwd ) macosx-passwd new ;

M: macosx passwd>new-passwd ( passwd -- macosx-passwd )
    [ call-next-method ] keep
    {
        [ pw_change>> >>change ]
        [ pw_class>> >>class ]
        [ pw_shell>> >>shell ]
        [ pw_expire>> >>expire ]
        [ pw_fields>> >>fields ]
    } cleave ;
