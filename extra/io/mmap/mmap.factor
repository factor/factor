! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations io.backend kernel quotations sequences
system alien alien.accessors accessors sequences.private ;
IN: io.mmap

TUPLE: mapped-file address handle length closed ;

: check-closed ( mapped-file -- mapped-file )
    dup closed>> [
        "Mapped file is closed" throw
    ] when ; inline

M: mapped-file length check-closed length>> ;

M: mapped-file nth-unsafe
    check-closed address>> swap alien-unsigned-1 ;

M: mapped-file set-nth-unsafe
    check-closed address>> swap set-alien-unsigned-1 ;

INSTANCE: mapped-file sequence

HOOK: (mapped-file) io-backend ( path length -- address handle )

: <mapped-file> ( path length -- mmap )
    [ >r normalize-path r> (mapped-file) ] keep
    f mapped-file boa ;

HOOK: close-mapped-file io-backend ( mmap -- )

M: mapped-file dispose ( mmap -- )
    dup closed>> [ drop ] [
        t >>closed close-mapped-file
    ] if ;

: with-mapped-file ( path length quot -- )
    >r <mapped-file> r> with-disposal ; inline
