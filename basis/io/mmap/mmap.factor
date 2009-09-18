! Copyright (C) 2007, 2009 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations destructors io.files io.files.info
io.backend kernel quotations system alien alien.accessors
accessors vocabs.loader combinators alien.c-types alien.data
math ;
IN: io.mmap

TUPLE: mapped-file < disposable address handle length ;

HOOK: (mapped-file-reader) os ( path length -- address handle )
HOOK: (mapped-file-r/w) os ( path length -- address handle )

ERROR: bad-mmap-size n ;

<PRIVATE

: prepare-mapped-file ( path quot -- mapped-file path' length )
    [
        [ normalize-path ] [ file-info size>> ] bi
        [ dup 0 <= [ bad-mmap-size ] [ 2drop ] if ]
        [ nip mapped-file new-disposable swap >>length ]
    ] dip 2tri [ >>address ] [ >>handle ] bi* ; inline

PRIVATE>

: <mapped-file-reader> ( path -- mmap )
    [ (mapped-file-reader) ] prepare-mapped-file ;

: <mapped-file> ( path -- mmap )
    [ (mapped-file-r/w) ] prepare-mapped-file ;

: <mapped-array> ( mmap c-type -- direct-array )
    [ [ address>> ] [ length>> ] bi ] dip
    [ heap-size /i ] keep
    <c-direct-array> ; inline

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
