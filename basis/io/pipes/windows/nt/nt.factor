! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.backend.windows libc
windows.types math.bitwise windows.kernel32 windows namespaces
make kernel sequences windows.errors assocs math.parser system
random combinators accessors io.pipes io.ports ;
IN: io.pipes.windows.nt

! This code is based on
! http://twistedmatrix.com/trac/browser/trunk/twisted/internet/iocpreactor/process.py

: create-named-pipe ( name -- handle )
    { PIPE_ACCESS_INBOUND FILE_FLAG_OVERLAPPED } flags
    PIPE_TYPE_BYTE
    1
    4096
    4096
    0
    default-security-attributes
    CreateNamedPipe opened-file ;

: open-other-end ( name -- handle )
    GENERIC_WRITE
    { FILE_SHARE_READ FILE_SHARE_WRITE } flags
    default-security-attributes
    OPEN_EXISTING
    FILE_FLAG_OVERLAPPED
    f
    CreateFile opened-file ;

: unique-pipe-name ( -- string )
    [
        "\\\\.\\pipe\\factor-" %
        pipe counter #
        "-" %
        32 random-bits #
        "-" %
        system-micros #
    ] "" make ;

M: winnt (pipe) ( -- pipe )
    [
        unique-pipe-name
        [ create-named-pipe ] [ open-other-end ] bi
        pipe boa
    ] with-destructors ;
