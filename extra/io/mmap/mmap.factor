! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations io.backend kernel quotations sequences
system alien alien.accessors sequences.private ;
IN: io.mmap

TUPLE: mapped-file length address handle closed? ;

: check-closed ( mapped-file -- mapped-file )
    dup mapped-file-closed? [
        "Mapped file is closed" throw
    ] when ; inline

M: mapped-file length check-closed mapped-file-length ;

M: mapped-file nth-unsafe
    check-closed mapped-file-address swap alien-unsigned-1 ;

M: mapped-file set-nth-unsafe
    check-closed mapped-file-address swap set-alien-unsigned-1 ;

INSTANCE: mapped-file sequence

HOOK: <mapped-file> io-backend ( path length -- mmap )

HOOK: close-mapped-file io-backend ( mmap -- )

M: mapped-file dispose ( mmap -- )
    check-closed
    t over set-mapped-file-closed?
    close-mapped-file ;

: with-mapped-file ( path length quot -- )
    >r <mapped-file> r> with-disposal ; inline
