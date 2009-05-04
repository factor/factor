! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs checksums checksums.crc32
io.encodings.utf8 io.files kernel namespaces sequences sets
source-files vocabs vocabs.errors vocabs.loader ;
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
    dup vocab changed-vocabs get and
    [ dup changed-vocabs get set-at ] [ drop ] if ;

: unchanged-vocab ( vocab -- )
    changed-vocabs get delete-at ;

: unchanged-vocabs ( vocabs -- )
    [ unchanged-vocab ] each ;

: changed-vocab? ( vocab -- ? )
    changed-vocabs get dup [ key? ] [ 2drop t ] if ;

: filter-changed ( vocabs -- vocabs' )
    [ changed-vocab? ] filter ;

SYMBOL: modified-sources
SYMBOL: modified-docs

: (to-refresh) ( vocab variable loaded? path -- )
    dup [
        swap [
            pick changed-vocab? [
                source-modified? [ get push ] [ 2drop ] if
            ] [ 3drop ] if
        ] [ drop get push ] if
    ] [ 2drop 2drop ] if ;

: to-refresh ( prefix -- modified-sources modified-docs unchanged )
    [
        V{ } clone modified-sources set
        V{ } clone modified-docs set

        child-vocabs [
            [
                [
                    [ modified-sources ]
                    [ vocab source-loaded?>> ]
                    [ vocab-source-path ]
                    tri (to-refresh)
                ] [
                    [ modified-docs ]
                    [ vocab docs-loaded?>> ]
                    [ vocab-docs-path ]
                    tri (to-refresh)
                ] bi
            ] each

            modified-sources get
            modified-docs get
        ]
        [ modified-docs get modified-sources get append diff ] bi
    ] with-scope ;

: do-refresh ( modified-sources modified-docs unchanged -- )
    unchanged-vocabs
    [
        [ [ vocab f >>source-loaded? drop ] each ]
        [ [ vocab f >>docs-loaded? drop ] each ] bi*
    ]
    [
        append prune
        [ unchanged-vocabs ]
        [ require-all load-failures. ] bi
    ] 2bi ;

: refresh ( prefix -- ) to-refresh do-refresh ;

: refresh-all ( -- ) "" refresh ;