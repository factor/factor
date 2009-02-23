! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel math.bitwise sequences system io.serial ;
IN: io.serial.unix

M: bsd lookup-baud ( m -- n )
    dup {
        0 50 75 110 134 150 200 300 600 1200 1800 2400 4800
        7200 9600 14400 19200 28800 38400 57600 76800 115200
        230400 460800 921600
    } member? [ invalid-baud ] unless ;

CONSTANT: TCSANOW     0
CONSTANT: TCSADRAIN   1
CONSTANT: TCSAFLUSH   2
CONSTANT: TCSASOFT    HEX: 10

CONSTANT: TCIFLUSH    1
CONSTANT: TCOFLUSH    2
CONSTANT: TCIOFLUSH   3
CONSTANT: TCOOFF      1
CONSTANT: TCOON       2
CONSTANT: TCIOFF      3
CONSTANT: TCION       4

! iflags
CONSTANT: IGNBRK      HEX: 00000001
CONSTANT: BRKINT      HEX: 00000002
CONSTANT: IGNPAR      HEX: 00000004
CONSTANT: PARMRK      HEX: 00000008
CONSTANT: INPCK       HEX: 00000010
CONSTANT: ISTRIP      HEX: 00000020
CONSTANT: INLCR       HEX: 00000040
CONSTANT: IGNCR       HEX: 00000080
CONSTANT: ICRNL       HEX: 00000100
CONSTANT: IXON        HEX: 00000200
CONSTANT: IXOFF       HEX: 00000400
CONSTANT: IXANY       HEX: 00000800
CONSTANT: IMAXBEL     HEX: 00002000
CONSTANT: IUTF8       HEX: 00004000

! oflags
CONSTANT: OPOST       HEX: 00000001
CONSTANT: ONLCR       HEX: 00000002
CONSTANT: OXTABS      HEX: 00000004
CONSTANT: ONOEOT      HEX: 00000008

! cflags
CONSTANT: CIGNORE     HEX: 00000001
CONSTANT: CSIZE       HEX: 00000300
CONSTANT: CS5         HEX: 00000000
CONSTANT: CS6         HEX: 00000100
CONSTANT: CS7         HEX: 00000200
CONSTANT: CS8         HEX: 00000300
CONSTANT: CSTOPB      HEX: 00000400
CONSTANT: CREAD       HEX: 00000800
CONSTANT: PARENB      HEX: 00001000
CONSTANT: PARODD      HEX: 00002000
CONSTANT: HUPCL       HEX: 00004000
CONSTANT: CLOCAL      HEX: 00008000
CONSTANT: CCTS_OFLOW  HEX: 00010000
CONSTANT: CRTS_IFLOW  HEX: 00020000
: CRTSCTS ( -- n )  { CCTS_OFLOW CRTS_IFLOW } flags ; inline
CONSTANT: CDTR_IFLOW  HEX: 00040000
CONSTANT: CDSR_OFLOW  HEX: 00080000
CONSTANT: CCAR_OFLOW  HEX: 00100000
CONSTANT: MDMBUF      HEX: 00100000

! lflags
CONSTANT: ECHOKE      HEX: 00000001
CONSTANT: ECHOE       HEX: 00000002
CONSTANT: ECHOK       HEX: 00000004
CONSTANT: ECHO        HEX: 00000008
CONSTANT: ECHONL      HEX: 00000010
CONSTANT: ECHOPRT     HEX: 00000020
CONSTANT: ECHOCTL     HEX: 00000040
CONSTANT: ISIG        HEX: 00000080
CONSTANT: ICANON      HEX: 00000100
CONSTANT: ALTWERASE   HEX: 00000200
CONSTANT: IEXTEN      HEX: 00000400
CONSTANT: EXTPROC     HEX: 00000800
CONSTANT: TOSTOP      HEX: 00400000
CONSTANT: FLUSHO      HEX: 00800000
CONSTANT: NOKERNINFO  HEX: 02000000
CONSTANT: PENDIN      HEX: 20000000
CONSTANT: NOFLSH      HEX: 80000000
