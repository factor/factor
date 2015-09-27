! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs checksums checksums.crc32
combinators.short-circuit io.encodings.utf8 io.files kernel
namespaces sequences sets source-files vocabs vocabs.loader ;
IN: vocabs.refresh

: source-modified? ( path -- ? )
    dup source-files get at [
        dup path>>
        dup exists? [
            utf8 file-lines crc32 checksum-lines
            swap checksum>> = not
        ] [
            2drop f
        ] if
    ] [
        exists?
    ] ?if ;

SYMBOL: changed-vocabs

: changed-vocab ( vocab -- )
    dup lookup-vocab changed-vocabs get and
    [ dup changed-vocabs get set-at ] [ drop ] if ;

: mark-unchanged-vocab  ( vocab-name -- )
    changed-vocabs get delete-at ;

: mark-unchanged-vocabs  ( vocab-names -- )
    [ mark-unchanged-vocab ] each ;

: changed-vocab-by-name? ( vocab -- ? )
    changed-vocabs get [ key? ] [ drop t ] if* ;

: (to-refresh) ( vocab-name loaded? path -- ? )
    [
        swap [
            swap changed-vocab-by-name? [
                source-modified?
            ] [ drop f ] if
        ] [ 2drop t ] if
    ] [ 2drop f ] if* ;

: vocab-source-modified? ( vocab-name -- ? )
    [ ]
    [ lookup-vocab source-loaded?>> ]
    [ vocab-source-path ] tri (to-refresh) ;

: vocab-docs-modified? ( vocab-name -- ? )
    [ ]
    [ lookup-vocab docs-loaded?>> ]
    [ vocab-docs-path ] tri (to-refresh) ;

: to-refresh ( prefix -- modified-sources modified-docs unchanged )
    loaded-child-vocab-names [ ".private" tail? ] reject
    [
        [ [ vocab-source-modified? ] filter ]
        [ [ vocab-docs-modified? ] filter ] bi
    ] [
        [ 2dup append ] dip swap diff
    ] bi ;

: do-refresh ( modified-sources modified-docs unchanged -- )
    mark-unchanged-vocabs
    [
        [ [ lookup-vocab f >>source-loaded? drop ] each ]
        [ [ lookup-vocab f >>docs-loaded? drop ] each ] bi*
    ]
    [
        union
        [ mark-unchanged-vocabs ]
        [ require-all ] bi
    ] 2bi ;

: refresh ( prefix -- ) to-refresh do-refresh ;

: refresh-all ( -- ) "" refresh ;
