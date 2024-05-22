! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.struct combinators
io.backend.unix io.ports io.serial io.streams.duplex kernel libc
literals math system unix unix.ffi io.serial.linux.ffi ;
IN: io.serial.linux

: fd>duplex-stream ( fd -- duplex-stream )
    <fd> init-fd
    [ <input-port> ] [ <output-port> ] bi <duplex-stream> ;

: open-rw ( path -- fd ) O_RDWR file-mode open-file  ;

: <file-rw> ( path -- stream ) open-rw fd>duplex-stream ;

: open-unix-serial-port ( serial-port -- )
    [
        path>> flags{ O_RDWR O_NOCTTY O_NDELAY } file-mode open-file
        fd>duplex-stream
    ] keep stream<< ;

: serial-fd ( serial -- fd )
    stream>> in>> handle>> fd>> ;

: get-fd-termios ( fd -- serial )
    termios new [ tcgetattr io-error ] keep ;

: set-termios ( serial -- )
    [ serial-fd get-fd-termios ] keep termios<< ;

: configure-termios ( serial -- )
    dup termios>>
    {
        [ [ iflag>> ] dip over [ iflag<< ] [ 2drop ] if ]
        [ [ oflag>> ] dip over [ oflag<< ] [ 2drop ] if ]
        [
            [
                [ cflag>> 0 or ] [ baud>> lookup-baud ] bi bitor
            ] dip cflag<<
        ]
        [ [ lflag>> ] dip over [ lflag<< ] [ 2drop ] if ]
    } 2cleave ;

: tciflush ( serial -- )
    serial-fd TCIFLUSH tcflush io-error ;

: apply-termios ( serial -- )
    [ serial-fd TCSANOW ]
    [ termios>> ] bi tcsetattr io-error ;

M: unix open-serial ( serial -- serial' )
    {
        [ open-unix-serial-port ]
        [ set-termios ]
        [ configure-termios ]
        [ tciflush ]
        [ apply-termios ]
        [ ]
    } cleave ;

M: unix default-serial-flags
    flags{ IGNPAR ICRNL } >>iflag
    flags{ } >>oflag
    flags{ CS8 CLOCAL CREAD } >>cflag
    flags{ ICANON } >>lflag ;

M: linux lookup-baud ( n -- n )
    H{
        { 0       0o0000000 }
        { 50      0o0000001 }
        { 75      0o0000002 }
        { 110     0o0000003 }
        { 134     0o0000004 }
        { 150     0o0000005 }
        { 200     0o0000006 }
        { 300     0o0000007 }
        { 600     0o0000010 }
        { 1200    0o0000011 }
        { 1800    0o0000012 }
        { 2400    0o0000013 }
        { 4800    0o0000014 }
        { 9600    0o0000015 }
        { 19200   0o0000016 }
        { 38400   0o0000017 }
        { 57600   0o0010001 }
        { 115200  0o0010002 }
        { 230400  0o0010003 }
        { 460800  0o0010004 }
        { 500000  0o0010005 }
        { 576000  0o0010006 }
        { 921600  0o0010007 }
        { 1000000 0o0010010 }
        { 1152000 0o0010011 }
        { 1500000 0o0010012 }
        { 2000000 0o0010013 }
        { 2500000 0o0010014 }
        { 3000000 0o0010015 }
        { 3500000 0o0010016 }
        { 4000000 0o0010017 }
    } ?at [ invalid-baud ] unless ;
