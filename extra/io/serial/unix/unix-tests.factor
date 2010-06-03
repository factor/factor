! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel math.bitwise io.serial io.serial.unix
literals ;
IN: io.serial.unix

: serial-obj ( -- obj )
    serial new
    "/dev/ttyS0" >>path ! linux
    ! "/dev/dty00" >>path ! netbsd
    ! "/dev/ttyd0" >>path ! freebsd
    ! "/dev/ttyU0" >>path ! openbsd
    19200 >>baud
    flags{ IGNPAR ICRNL } >>iflag
    flags{ } >>oflag
    flags{ CS8 CLOCAL CREAD } >>cflag
    flags{ ICANON } >>lflag ;

: serial-test ( -- serial )
    serial-obj
    open-serial
    dup get-termios >>termios
    dup configure-termios
    dup tciflush
    dup apply-termios ;
