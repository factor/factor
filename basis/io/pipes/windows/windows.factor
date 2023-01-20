! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs combinators
destructors io io.files.windows io.pipes
io.ports kernel libc literals make math.bitwise math.parser
namespaces random sequences system windows windows.errors
windows.kernel32 windows.types ;
IN: io.pipes.windows

! This code is based on
! https://twistedmatrix.com/trac/browser/trunk/twisted/internet/iocpreactor/process.py

: create-named-pipe ( name -- handle )
    flags{ PIPE_ACCESS_INBOUND FILE_FLAG_OVERLAPPED }
    PIPE_TYPE_BYTE
    1
    4096
    4096
    0
    default-security-attributes
    CreateNamedPipe opened-file ;

: open-other-end ( name -- handle )
    GENERIC_WRITE
    flags{ FILE_SHARE_READ FILE_SHARE_WRITE }
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
        nano-count #
    ] "" make ;

M: windows (pipe)
    [
        unique-pipe-name
        [ create-named-pipe ] [ open-other-end ] bi
        pipe boa
    ] with-destructors ;
