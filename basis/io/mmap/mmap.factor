! Copyright (C) 2007, 2008 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations destructors io.files io.files.info
io.backend kernel quotations system alien alien.accessors
accessors system vocabs.loader combinators alien.c-types
math ;
IN: io.mmap

TUPLE: mapped-file address handle length disposed ;

HOOK: (mapped-file-reader) os ( path length -- address handle )
HOOK: (mapped-file-r/w) os ( path length -- address handle )

ERROR: bad-mmap-size path size ;

<PRIVATE

: prepare-mapped-file ( path -- path' n )
    [ normalize-path ] [ file-info size>> ] bi
    dup 0 <= [ bad-mmap-size ] when ;

PRIVATE>

: <mapped-file-reader> ( path -- mmap )
    prepare-mapped-file
    [ (mapped-file-reader) ] keep
    f mapped-file boa ;

: <mapped-file> ( path -- mmap )
    prepare-mapped-file
    [ (mapped-file-r/w) ] keep
    f mapped-file boa ;

HOOK: close-mapped-file io-backend ( mmap -- )

M: mapped-file dispose* ( mmap -- ) close-mapped-file ;

: with-mapped-file ( path quot -- )
    [ <mapped-file> ] dip with-disposal ; inline

: with-mapped-file-reader ( path quot -- )
    [ <mapped-file-reader> ] dip with-disposal ; inline

{
    { [ os unix? ] [ "io.mmap.unix" require ] }
    { [ os winnt? ] [ "io.mmap.windows" require ] }
} cond
