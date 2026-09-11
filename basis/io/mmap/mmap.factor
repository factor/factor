! Copyright (C) 2007, 2009 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data combinators
destructors io.backend io.files.info kernel locals math system vocabs ;
IN: io.mmap

TUPLE: mapped-file < disposable address handle length ;

ERROR: bad-mmap-size n ;

<PRIVATE

HOOK: (mapped-file-reader) os ( path length -- address handle )
HOOK: (mapped-file-r/w) os ( path length -- address handle )

:: prepare-mapped-file ( path quot -- mapped-file )
    path normalize-path :> path'
    path' file-info size>> :> length
    length 0 <= [ length bad-mmap-size ] when
    path' length quot call :> ( address handle )
    mapped-file new-disposable
        address >>address
        handle >>handle
        length >>length ; inline

PRIVATE>

: <mapped-file-reader> ( path -- mmap )
    [ (mapped-file-reader) ] prepare-mapped-file ; inline

: <mapped-file> ( path -- mmap )
    [ (mapped-file-r/w) ] prepare-mapped-file ; inline

: <mapped-array> ( mmap c-type -- direct-array )
    [ [ address>> ] [ length>> ] bi ] dip
    [ heap-size /i ] keep
    <c-direct-array> ; inline

HOOK: close-mapped-file io-backend ( mmap -- )

M: mapped-file dispose* close-mapped-file ;

: with-mapped-file ( path quot -- )
    [ <mapped-file> ] dip with-disposal ; inline

: with-mapped-file-reader ( path quot -- )
    [ <mapped-file-reader> ] dip with-disposal ; inline

<PRIVATE

: (with-mapped-array) ( c-type quot -- )
    [ [ <mapped-array> ] curry ] dip compose with-disposal ; inline

PRIVATE>

: with-mapped-array ( path c-type quot -- )
    [ <mapped-file> ] 2dip (with-mapped-array) ; inline

: with-mapped-array-reader ( path c-type quot -- )
    [ <mapped-file-reader> ] 2dip (with-mapped-array) ; inline

{
    { [ os unix? ] [ "io.mmap.unix" require ] }
    { [ os windows? ] [ "io.mmap.windows" require ] }
} cond
