! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.algebra combinators
combinators.short-circuit continuations io.directories
io.encodings.utf8 io.files io.pathnames kernel make math.parser
memoize namespaces sequences splitting summary system vocabs
vocabs.loader words ;
IN: vocabs.metadata

: check-vocab ( vocab -- vocab )
    dup find-vocab-root [ no-vocab ] unless ;

: vocab-file-path ( vocab name -- path/f )
    [ dup vocab-dir ] [ append-path ] bi* vocab-append-path ;

MEMO: vocab-file-lines ( vocab name -- lines/f )
    vocab-file-path dup [
        dup file-exists? [
            utf8 file-lines harvest
        ] [
            drop f
        ] if
    ] when ;

: set-vocab-file-lines ( lines vocab name -- )
    dupd vocab-file-path or* [
        swap [ ?delete-file ] [ swap utf8 set-file-lines ] if-empty
        \ vocab-file-lines reset-memoized
    ] [ vocab-name no-vocab ] if ;

: vocab-resources-path ( vocab -- path/f )
    "resources.txt" vocab-file-path ;

: vocab-resources ( vocab -- patterns )
    "resources.txt" vocab-file-lines ;

: vocab-summary-path ( vocab -- path/f )
    "summary.txt" vocab-file-path ;

: vocab-summary ( vocab -- summary )
    "summary.txt" vocab-file-lines [ first ] [ f ] if* ;

: vocab-in-root-summary ( vocab -- string )
    [ vocab-summary ] [
        vocab-name dup
        ".private" ?tail drop find-vocab-root
        [ "`" "'" surround " in " glue ] when*
    ] bi over [ ", " glue ] [ nip ] if ;

M: vocab summary
    [
        dup vocab-in-root-summary %
        " (" %
        words>> assoc-size #
        " words)" %
    ] "" make ;

M: vocab-link summary vocab-in-root-summary ;

: vocab-tags-path ( vocab -- path/f )
    "tags.txt" vocab-file-path ;

: vocab-tags ( vocab -- tags )
    "tags.txt" vocab-file-lines ;

: vocab-authors-path ( vocab -- path/f )
    "authors.txt" vocab-file-path ;

: vocab-authors ( vocab -- authors )
    "authors.txt" vocab-file-lines ;

: vocab-platforms-path ( vocab -- path/f )
    "platforms.txt" vocab-file-path ;

ERROR: bad-platform name ;

: vocab-platforms ( vocab -- platforms )
    "platforms.txt" vocab-file-lines
    [ [ "system" lookup-word ] [ bad-platform ] ?unless ] map ;

: supported-platform? ( platforms -- ? )
    [ t ] [ [ os swap class<= ] any? ] if-empty ;

: don't-load? ( vocab -- ? )
    {
        [ vocab-tags "not loaded" swap member? ]
        [ vocab-platforms supported-platform? not ]
    } 1|| ;

: don't-test? ( vocab -- ? )
    vocab-tags "not tested" swap member? ;

TUPLE: unsupported-platform vocab requires ;

: throw-unsupported-platform ( vocab requires -- )
    unsupported-platform boa throw-continue ;

M: unsupported-platform summary
    drop "Current operating system not supported by this vocabulary" ;

: file-exists?, ( path -- )
    [ dup file-exists? [ , ] [ drop ] if ] when* ;

: vocab-metadata-files ( vocab -- paths )
    [
        {
            [ vocab-authors-path file-exists?, ]
            [ vocab-platforms-path file-exists?, ]
            [ vocab-resources-path file-exists?, ]
            [ vocab-summary-path file-exists?, ]
            [ vocab-tags-path file-exists?, ]
        } cleave
    ] { } make ;

[
    dup vocab-platforms dup supported-platform?
    [ 2drop ] [ [ vocab-name ] dip throw-unsupported-platform ] if
] check-vocab-hook set-global
