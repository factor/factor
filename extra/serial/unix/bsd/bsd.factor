! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel math.bitfields sequences system serial ;
IN: serial.unix

M: bsd lookup-baud ( m -- n )
    dup {
        0 50 75 110 134 150 200 300 600 1200 1800 2400 4800
        7200 9600 14400 19200 28800 38400 57600 76800 115200
        230400 460800 921600
    } member? [ invalid-baud ] unless ;

: TCSANOW     0 ; inline
: TCSADRAIN   1 ; inline
: TCSAFLUSH   2 ; inline
: TCSASOFT    HEX: 10 ; inline

: TCIFLUSH    1 ; inline
: TCOFLUSH    2 ; inline
: TCIOFLUSH   3 ; inline
: TCOOFF      1 ; inline
: TCOON       2 ; inline
: TCIOFF      3 ; inline
: TCION       4 ; inline

! iflags
: IGNBRK      HEX: 00000001 ; inline
: BRKINT      HEX: 00000002 ; inline
: IGNPAR      HEX: 00000004 ; inline
: PARMRK      HEX: 00000008 ; inline
: INPCK       HEX: 00000010 ; inline
: ISTRIP      HEX: 00000020 ; inline
: INLCR       HEX: 00000040 ; inline
: IGNCR       HEX: 00000080 ; inline
: ICRNL       HEX: 00000100 ; inline
: IXON        HEX: 00000200 ; inline
: IXOFF       HEX: 00000400 ; inline
: IXANY       HEX: 00000800 ; inline
: IMAXBEL     HEX: 00002000 ; inline
: IUTF8       HEX: 00004000 ; inline

! oflags
: OPOST       HEX: 00000001 ; inline
: ONLCR       HEX: 00000002 ; inline
: OXTABS      HEX: 00000004 ; inline
: ONOEOT      HEX: 00000008 ; inline

! cflags
: CIGNORE     HEX: 00000001 ; inline
: CSIZE       HEX: 00000300 ; inline
: CS5         HEX: 00000000 ; inline
: CS6         HEX: 00000100 ; inline
: CS7         HEX: 00000200 ; inline
: CS8         HEX: 00000300 ; inline
: CSTOPB      HEX: 00000400 ; inline
: CREAD       HEX: 00000800 ; inline
: PARENB      HEX: 00001000 ; inline
: PARODD      HEX: 00002000 ; inline
: HUPCL       HEX: 00004000 ; inline
: CLOCAL      HEX: 00008000 ; inline
: CCTS_OFLOW  HEX: 00010000 ; inline
: CRTS_IFLOW  HEX: 00020000 ; inline
: CRTSCTS     { CCTS_OFLOW CRTS_IFLOW } flags ; inline
: CDTR_IFLOW  HEX: 00040000 ; inline
: CDSR_OFLOW  HEX: 00080000 ; inline
: CCAR_OFLOW  HEX: 00100000 ; inline
: MDMBUF      HEX: 00100000 ; inline

! lflags
: ECHOKE      HEX: 00000001 ; inline
: ECHOE       HEX: 00000002 ; inline
: ECHOK       HEX: 00000004 ; inline
: ECHO        HEX: 00000008 ; inline
: ECHONL      HEX: 00000010 ; inline
: ECHOPRT     HEX: 00000020 ; inline
: ECHOCTL     HEX: 00000040 ; inline
: ISIG        HEX: 00000080 ; inline
: ICANON      HEX: 00000100 ; inline
: ALTWERASE   HEX: 00000200 ; inline
: IEXTEN      HEX: 00000400 ; inline
: EXTPROC     HEX: 00000800 ; inline
: TOSTOP      HEX: 00400000 ; inline
: FLUSHO      HEX: 00800000 ; inline
: NOKERNINFO  HEX: 02000000 ; inline
: PENDIN      HEX: 20000000 ; inline
: NOFLSH      HEX: 80000000 ; inline
