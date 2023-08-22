! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes.struct combinators io.backend.unix
io.ports io.serial io.streams.duplex kernel libc literals math
system unix unix.ffi io.serial.linux.ffi ;
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
