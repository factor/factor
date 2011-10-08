! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors io io.serial io.serial.unix kernel literals
math.bitwise tools.test ;
IN: io.serial.unix

! "/dev/ttyS0" ! netbsd
! "/dev/dty00" ! netbsd
! "/dev/ttyd0" ! freebsd
! "/dev/ttyU0" ! openbsd

: <serial-port-test> ( -- serial-port )
    "/dev/ttyS0" 19200 <serial-port> ;

: with-serial-port-test ( quot -- )
    [ <serial-port-test> ] dip with-serial-port ; inline

! [ ] [
    ! [ "hello" over stream-write stream-flush ] with-serial-port-test
! ] unit-test
