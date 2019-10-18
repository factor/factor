! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.directories io.files io.pathnames kernel make
sequences vocabs vocabs.loader ;
IN: vocabs.files

: vocab-tests-path ( vocab -- path )
    dup "-tests.factor" append-vocab-dir vocab-append-path ;

: vocab-tests-file ( vocab -- path/f )
    vocab-tests-path dup
    [ dup exists? [ drop f ] unless ] [ drop f ] if ;

: vocab-tests-dir ( vocab -- paths )
    dup vocab-dir "tests" append-path vocab-append-path dup [
        dup exists? [
            dup directory-files [ ".factor" tail? ] filter
            [ append-path ] with map
        ] [ drop f ] if
    ] [ drop f ] if ;

: vocab-tests ( vocab -- tests )
    [
        [ vocab-tests-file [ , ] when* ]
        [ vocab-tests-dir [ % ] when* ] bi
    ] { } make ;

: vocab-files ( vocab -- seq )
    [
        [ vocab-source-path [ , ] when* ]
        [ vocab-docs-path [ , ] when* ]
        [ vocab-tests % ] tri
    ] { } make ;
