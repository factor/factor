! Copyright (C) 2009, 2010 Slava Pestov, Joe Groff.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.algebra
combinators.short-circuit continuations io.directories
io.encodings.utf8 io.files io.pathnames kernel make math.parser
memoize namespaces sequences sets summary system vocabs
vocabs.loader words ;
IN: vocabs.metadata

: check-vocab ( vocab -- vocab )
    dup find-vocab-root [ no-vocab ] unless ;

MEMO: vocab-file-lines ( vocab name -- lines/f )
    vocab-append-path dup [
        dup exists? [
            utf8 file-lines harvest
        ] [
            drop f
        ] if
    ] when ;

: set-vocab-file-lines ( lines vocab name -- )
    dupd vocab-append-path [
        swap [ ?delete-file ] [ swap utf8 set-file-lines ] if-empty
        \ vocab-file-lines reset-memoized
    ] [ vocab-name no-vocab ] ?if ;

: vocab-resources-path ( vocab -- string )
    vocab-dir "resources.txt" append-path ;

: vocab-resources ( vocab -- patterns )
    dup vocab-resources-path vocab-file-lines ;

: vocab-summary-path ( vocab -- string )
    vocab-dir "summary.txt" append-path ;

: vocab-summary ( vocab -- summary )
    dup dup vocab-summary-path vocab-file-lines
    [
        vocab-name " vocabulary" append
    ] [
        nip first
    ] if-empty ;

M: vocab summary
    [
        dup vocab-summary %
        " (" %
        words>> assoc-size #
        " words)" %
    ] "" make ;

M: vocab-link summary vocab-summary ;

: vocab-tags-path ( vocab -- string )
    vocab-dir "tags.txt" append-path ;

: vocab-tags ( vocab -- tags )
    dup vocab-tags-path vocab-file-lines ;

: vocab-authors-path ( vocab -- string )
    vocab-dir "authors.txt" append-path ;

: vocab-authors ( vocab -- authors )
    dup vocab-authors-path vocab-file-lines ;

: vocab-platforms-path ( vocab -- string )
    vocab-dir "platforms.txt" append-path ;

ERROR: bad-platform name ;

: vocab-platforms ( vocab -- platforms )
    dup vocab-platforms-path vocab-file-lines
    [ dup "system" lookup-word [ ] [ bad-platform ] ?if ] map ;

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

[
    dup vocab-platforms dup supported-platform?
    [ 2drop ] [ [ vocab-name ] dip throw-unsupported-platform ] if
] check-vocab-hook set-global
