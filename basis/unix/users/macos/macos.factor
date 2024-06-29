! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators accessors kernel unix.users
system ;
IN: unix.users.macos

TUPLE: macos-passwd < passwd change class expire fields ;

M: macos new-passwd macos-passwd new ;

M: macos passwd>new-passwd
    [ call-next-method ] keep
    {
        [ pw_change>> >>change ]
        [ pw_class>> >>class ]
        [ pw_shell>> >>shell ]
        [ pw_expire>> >>expire ]
        [ pw_fields>> >>fields ]
    } cleave ;
