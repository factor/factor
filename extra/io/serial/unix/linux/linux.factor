! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs alien.syntax kernel serial system unix ;
IN: io.serial.unix

: TCSANOW     0 ; inline
: TCSADRAIN   1 ; inline
: TCSAFLUSH   2 ; inline

: TCIFLUSH    0 ; inline
: TCOFLUSH    1 ; inline
: TCIOFLUSH   2 ; inline

: TCOOFF      0 ; inline
: TCOON       1 ; inline
: TCIOFF      2 ; inline
: TCION       3 ; inline

! iflag
: IGNBRK  OCT: 0000001 ; inline
: BRKINT  OCT: 0000002 ; inline
: IGNPAR  OCT: 0000004 ; inline
: PARMRK  OCT: 0000010 ; inline
: INPCK   OCT: 0000020 ; inline
: ISTRIP  OCT: 0000040 ; inline
: INLCR   OCT: 0000100 ; inline
: IGNCR   OCT: 0000200 ; inline
: ICRNL   OCT: 0000400 ; inline
: IUCLC   OCT: 0001000 ; inline
: IXON    OCT: 0002000 ; inline
: IXANY   OCT: 0004000 ; inline
: IXOFF   OCT: 0010000 ; inline
: IMAXBEL OCT: 0020000 ; inline
: IUTF8   OCT: 0040000 ; inline

! oflag
: OPOST   OCT: 0000001 ; inline
: OLCUC   OCT: 0000002 ; inline
: ONLCR   OCT: 0000004 ; inline
: OCRNL   OCT: 0000010 ; inline
: ONOCR   OCT: 0000020 ; inline
: ONLRET  OCT: 0000040 ; inline
: OFILL   OCT: 0000100 ; inline
: OFDEL   OCT: 0000200 ; inline
: NLDLY  OCT: 0000400 ; inline
:   NL0  OCT: 0000000 ; inline
:   NL1  OCT: 0000400 ; inline
: CRDLY  OCT: 0003000 ; inline
:   CR0  OCT: 0000000 ; inline
:   CR1  OCT: 0001000 ; inline
:   CR2  OCT: 0002000 ; inline
:   CR3  OCT: 0003000 ; inline
: TABDLY OCT: 0014000 ; inline
:   TAB0 OCT: 0000000 ; inline
:   TAB1 OCT: 0004000 ; inline
:   TAB2 OCT: 0010000 ; inline
:   TAB3 OCT: 0014000 ; inline
: BSDLY  OCT: 0020000 ; inline
:   BS0  OCT: 0000000 ; inline
:   BS1  OCT: 0020000 ; inline
: FFDLY  OCT: 0100000 ; inline
:   FF0  OCT: 0000000 ; inline
:   FF1  OCT: 0100000 ; inline

! cflags
: CSIZE   OCT: 0000060 ; inline
:   CS5   OCT: 0000000 ; inline
:   CS6   OCT: 0000020 ; inline
:   CS7   OCT: 0000040 ; inline
:   CS8   OCT: 0000060 ; inline
: CSTOPB  OCT: 0000100 ; inline
: CREAD   OCT: 0000200 ; inline
: PARENB  OCT: 0000400 ; inline
: PARODD  OCT: 0001000 ; inline
: HUPCL   OCT: 0002000 ; inline
: CLOCAL  OCT: 0004000 ; inline
: CIBAUD  OCT: 002003600000 ; inline
: CRTSCTS OCT: 020000000000 ; inline

! lflags
: ISIG    OCT: 0000001 ; inline
: ICANON  OCT: 0000002 ; inline
: XCASE  OCT: 0000004 ; inline
: ECHO    OCT: 0000010 ; inline
: ECHOE   OCT: 0000020 ; inline
: ECHOK   OCT: 0000040 ; inline
: ECHONL  OCT: 0000100 ; inline
: NOFLSH  OCT: 0000200 ; inline
: TOSTOP  OCT: 0000400 ; inline
: ECHOCTL OCT: 0001000 ; inline
: ECHOPRT OCT: 0002000 ; inline
: ECHOKE  OCT: 0004000 ; inline
: FLUSHO  OCT: 0010000 ; inline
: PENDIN  OCT: 0040000 ; inline
: IEXTEN  OCT: 0100000 ; inline

M: linux lookup-baud ( n -- n )
    dup H{
        { 0 OCT: 0000000 }
        { 50    OCT: 0000001 }
        { 75    OCT: 0000002 }
        { 110   OCT: 0000003 }
        { 134   OCT: 0000004 }
        { 150   OCT: 0000005 }
        { 200   OCT: 0000006 }
        { 300   OCT: 0000007 }
        { 600   OCT: 0000010 }
        { 1200  OCT: 0000011 }
        { 1800  OCT: 0000012 }
        { 2400  OCT: 0000013 }
        { 4800  OCT: 0000014 }
        { 9600  OCT: 0000015 }
        { 19200 OCT: 0000016 }
        { 38400 OCT: 0000017 }
        { 57600   OCT: 0010001 }
        { 115200  OCT: 0010002 }
        { 230400  OCT: 0010003 }
        { 460800  OCT: 0010004 }
        { 500000  OCT: 0010005 }
        { 576000  OCT: 0010006 }
        { 921600  OCT: 0010007 }
        { 1000000 OCT: 0010010 }
        { 1152000 OCT: 0010011 }
        { 1500000 OCT: 0010012 }
        { 2000000 OCT: 0010013 }
        { 2500000 OCT: 0010014 }
        { 3000000 OCT: 0010015 }
        { 3500000 OCT: 0010016 }
        { 4000000 OCT: 0010017 }
    } at* [ nip ] [ drop invalid-baud ] if ;
