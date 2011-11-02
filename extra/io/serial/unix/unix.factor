! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax alien.data 
classes.struct combinators io.ports io.streams.duplex
system kernel math math.bitwise vocabs io.serial
io.serial.unix.termios io.backend.unix unix unix.ffi
literals ;
IN: io.serial.unix

<< {
    { [ os linux? ] [ "io.serial.unix.linux" ] }
    { [ os bsd? ] [ "io.serial.unix.bsd" ] }
} cond require >>

FUNCTION: speed_t cfgetispeed ( termios* t ) ;
FUNCTION: speed_t cfgetospeed ( termios* t ) ;
FUNCTION: int cfsetispeed ( termios* t, speed_t s ) ;
FUNCTION: int cfsetospeed ( termios* t, speed_t s ) ;
FUNCTION: int tcgetattr ( int i1, termios* t ) ;
FUNCTION: int tcsetattr ( int i1, int i2, termios* t ) ;
FUNCTION: int tcdrain ( int i1 ) ;
FUNCTION: int tcflow ( int i1, int i2 ) ;
FUNCTION: int tcflush ( int i1, int i2 ) ;
FUNCTION: int tcsendbreak ( int i1, int i2 ) ;
FUNCTION: void cfmakeraw ( termios* t ) ;
FUNCTION: int cfsetspeed ( termios* t, speed_t s ) ;

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

: set-termios ( serial -- )
    [
        serial-fd
        termios <struct> [ tcgetattr io-error ] keep
    ] keep termios<< ;

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
