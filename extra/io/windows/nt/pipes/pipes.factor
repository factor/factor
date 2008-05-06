! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types arrays destructors io io.windows libc
windows.types math windows.kernel32 windows namespaces kernel
sequences windows.errors assocs math.parser system random
combinators accessors io.pipes ;
IN: io.windows.nt.pipes

! This code is based on
! http://twistedmatrix.com/trac/browser/trunk/twisted/internet/iocpreactor/process.py

: create-named-pipe ( name in-mode -- handle )
    FILE_FLAG_OVERLAPPED bitor
    PIPE_TYPE_BYTE
    1
    4096
    4096
    0
    security-attributes-inherit
    CreateNamedPipe
    dup win32-error=0/f
    dup add-completion ;

: open-other-end ( name out-mode -- handle )
    FILE_SHARE_READ FILE_SHARE_WRITE bitor
    security-attributes-inherit
    OPEN_EXISTING
    FILE_FLAG_OVERLAPPED
    f
    CreateFile
    dup win32-error=0/f
    dup add-completion ;

: <pipe> ( name in-mode out-mode -- pipe )
    [
        >r over >r create-named-pipe dup close-later
        r> r> open-other-end dup close-later
        pipe boa
    ] with-destructors ;

: <incoming-pipe> ( name -- pipe )
    PIPE_ACCESS_INBOUND GENERIC_WRITE <pipe> ;

: <outgoing-pipe> ( name -- pipe )
    PIPE_ACCESS_OUTBOUND GENERIC_READ <pipe> ;

: unique-pipe-name ( -- string )
    [
        "\\\\.\\pipe\\factor-" %
        pipe counter #
        "-" %
        32 random-bits #
        "-" %
        millis #
    ] "" make ;

: <unique-incoming-pipe> ( -- pipe )
    unique-pipe-name <incoming-pipe> ;

: <unique-outgoing-pipe> ( -- pipe )
    unique-pipe-name <outgoing-pipe> ;

! /dev/null simulation
: null-input ( -- pipe )
    <unique-outgoing-pipe>
    [ in>> ] [ out>> CloseHandle drop ] bi ;

: null-output ( -- pipe )
    <unique-incoming-pipe>
    [ in>> CloseHandle drop ] [ out>> ] bi ;

: null-pipe ( mode -- pipe )
    {
        { GENERIC_READ [ null-input ] }
        { GENERIC_WRITE [ null-output ] }
    } case ;
