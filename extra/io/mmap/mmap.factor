! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations io.backend kernel quotations sequences
system alien sequences.private ;
IN: io.mmap

TUPLE: mapped-file length address handle ;

M: mapped-file length mapped-file-length ;

M: mapped-file nth-unsafe
    mapped-file-address swap alien-unsigned-1 ;

M: mapped-file set-nth-unsafe
    mapped-file-address swap set-alien-unsigned-1 ;

INSTANCE: mapped-file sequence

HOOK: <mapped-file> io-backend ( path length -- mmap )
HOOK: close-mapped-file io-backend ( mmap -- )

: with-mapped-file ( path length quot -- )
    >r <mapped-file> r>
    [ keep ] curry
    [ close-mapped-file ] [ ] cleanup ; inline

USE-IF: unix? io.unix.mmap
USE-IF: windows? io.windows.mmap
