! Copyright (C) 2007 Elie Chaftari, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax destructors hexdump io
io.buffers io.nonblocking io.sockets
io.unix.backend io.unix.files kernel libc locals math qualified
sequences io.sniffer.backend ;
QUALIFIED: unix
IN: io.sniffer.bsd

M: unix-io destruct-handle ( obj -- ) unix:close ;

C-UNION: ifreq_props "sockaddr-in" "short" "int" "caddr_t" ;
C-STRUCT: ifreq { { "char" 16 } "name" } { "ifreq_props" "props" } ;

TUPLE: sniffer-spec path ifname ;

C: <sniffer-spec> sniffer-spec

: IOCPARM_MASK   0x1fff ; inline
: IOCPARM_MAX    IOCPARM_MASK 1+ ; inline
: IOC_VOID       0x20000000 ; inline
: IOC_OUT        0x40000000 ; inline
: IOC_IN         0x80000000 ; inline
: IOC_INOUT      IOC_IN IOC_OUT bitor ; inline
: IOC_DIRMASK    0xe0000000 ; inline

:: ioc ( inout group num len -- n )
    group first 8 shift num bitor
    len IOCPARM_MASK bitand 16 shift bitor
    inout bitor ;

: io-len ( type -- n )
    dup zero? [ heap-size ] unless ;

: io ( group num -- n )
    IOC_VOID -rot 0 io-len ioc ;

: ior ( group num type -- n )
    IOC_OUT -roll io-len ioc ;

: iow ( group num type -- n )
    IOC_IN -roll io-len ioc ;

: iowr ( group num type -- n )
    IOC_INOUT -roll io-len ioc ;

: BIOCGBLEN ( -- n ) "B" 102 "uint" ior ; inline
: BIOCSETIF ( -- n ) "B" 108 "ifreq" iow ; inline
: BIOCPROMISC ( -- n ) "B" 105 io ; inline 
: BIOCIMMEDIATE ( -- n ) "B" 112 "uint" iow ; inline

: make-ifreq-props ( ifname -- ifreq )
    "ifreq" <c-object>
    12 <short> 16 0 pad-right over set-ifreq-props
    swap malloc-char-string dup free-always
    over set-ifreq-name ;

: make-ioctl-buffer ( fd -- buffer )
    BIOCGBLEN "char*" <c-object>
    [ unix:ioctl io-error ] keep
    *int <buffer> ;

: ioctl-BIOSETIF ( fd ifreq -- )
    >r BIOCSETIF r> unix:ioctl io-error ;

: ioctl-BIOPROMISC ( fd -- )
    BIOCPROMISC f unix:ioctl io-error ;

: ioctl-BIOCIMMEDIATE
    BIOCIMMEDIATE 1 <int> unix:ioctl io-error ;

: ioctl-sniffer-fd ( fd ifname -- )
    dupd make-ifreq-props ioctl-BIOSETIF
    dup ioctl-BIOPROMISC
    ioctl-BIOCIMMEDIATE ;

M: unix-io <sniffer> ( obj -- sniffer )
    [
        [
            sniffer-spec-path
            open-read
            dup close-later
        ] keep
        dupd sniffer-spec-ifname ioctl-sniffer-fd
        dup make-ioctl-buffer
        input-port <port> <line-reader>
        \ sniffer construct-delegate
    ] with-destructors ;

