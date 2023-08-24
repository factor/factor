! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.directories io.files io.pathnames kernel
make sequences splitting vocabs vocabs.loader vocabs.metadata ;
IN: vocabs.files

: vocab-tests-path ( vocab -- path/f )
    dup "-tests.factor" append-vocab-dir vocab-append-path ;

: vocab-tests-dir ( vocab -- paths )
    dup vocab-dir "tests" append-path vocab-append-path [
        dup file-exists? [
            dup directory-files [ ".factor" tail? ] filter
            [ append-path ] with map
        ] [ drop f ] if
    ] [ f ] if* ;

: vocab-tests ( vocab -- paths )
    vocab-name ".private" ?tail drop
    [
        [ vocab-tests-path file-exists?, ]
        [ vocab-tests-dir % ] bi
    ] { } make ;

: vocab-files ( vocab -- paths )
    [
        {
            [ vocab-source-path file-exists?, ]
            [ vocab-docs-path file-exists?, ]
            [ vocab-tests % ]
        } cleave
    ] { } make ;
