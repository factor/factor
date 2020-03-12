! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators io.directories io.files io.pathnames kernel
make sequences vocabs.loader ;
IN: vocabs.files

: vocab-tests-path ( vocab -- path/f )
    dup "-tests.factor" append-vocab-dir vocab-append-path ;

: vocab-tests-dir ( vocab -- paths )
    dup vocab-dir "tests" append-path vocab-append-path [
        dup exists? [
            dup directory-files [ ".factor" tail? ] filter
            [ append-path ] with map
        ] [ drop f ] if
    ] [ f ] if* ;

: vocab-tests ( vocab -- paths )
    [
        [ vocab-tests-path [ dup exists? [ , ] [ drop ] if ] when* ]
        [ vocab-tests-dir % ] bi
    ] { } make ;

: vocab-files ( vocab -- paths )
    [
        {
            [ vocab-source-path [ , ] when* ]
            [ vocab-docs-path [ , ] when* ]
            [ vocab-tests % ]
        } cleave
    ] { } make ;
