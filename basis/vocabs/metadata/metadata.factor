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

MEMO: vocab-file-contents ( vocab name -- seq )
    vocab-append-path dup
    [ dup exists? [ utf8 file-lines ] [ drop f ] if ] when ;

: set-vocab-file-contents ( seq vocab name -- )
    dupd vocab-append-path [
        swap [ ?delete-file ] [ swap utf8 set-file-lines ] if-empty
        \ vocab-file-contents reset-memoized
    ] [ vocab-name no-vocab ] ?if ;

: vocab-windows-icon-path ( vocab -- string )
    vocab-dir "icon.ico" append-path ;

: vocab-mac-icon-path ( vocab -- string )
    vocab-dir "icon.icns" append-path ;

: vocab-resources-path ( vocab -- string )
    vocab-dir "resources.txt" append-path ;

: vocab-resources ( vocab -- patterns )
    dup vocab-resources-path vocab-file-contents harvest ;

: set-vocab-resources ( patterns vocab -- )
    dup vocab-resources-path set-vocab-file-contents ;

: vocab-summary-path ( vocab -- string )
    vocab-dir "summary.txt" append-path ;

: vocab-summary ( vocab -- summary )
    dup dup vocab-summary-path vocab-file-contents
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

: set-vocab-summary ( string vocab -- )
    [ 1array ] dip
    dup vocab-summary-path
    set-vocab-file-contents ;

: vocab-tags-path ( vocab -- string )
    vocab-dir "tags.txt" append-path ;

: vocab-tags ( vocab -- tags )
    dup vocab-tags-path vocab-file-contents harvest ;

: set-vocab-tags ( tags vocab -- )
    dup vocab-tags-path set-vocab-file-contents ;

: add-vocab-tags ( tags vocab -- )
    [ vocab-tags append members ] keep set-vocab-tags ;

: remove-vocab-tags ( tags vocab -- )
    [ vocab-tags swap diff ] keep set-vocab-tags ;

: vocab-authors-path ( vocab -- string )
    vocab-dir "authors.txt" append-path ;

: vocab-authors ( vocab -- authors )
    dup vocab-authors-path vocab-file-contents harvest ;

: set-vocab-authors ( authors vocab -- )
    dup vocab-authors-path set-vocab-file-contents ;

: vocab-platforms-path ( vocab -- string )
    vocab-dir "platforms.txt" append-path ;

ERROR: bad-platform name ;

: vocab-platforms ( vocab -- platforms )
    dup vocab-platforms-path vocab-file-contents
    [ dup "system" lookup-word [ ] [ bad-platform ] ?if ] map ;

: set-vocab-platforms ( platforms vocab -- )
    [ [ name>> ] map ] dip
    dup vocab-platforms-path set-vocab-file-contents ;

: supported-platform? ( platforms -- ? )
    [ t ] [ [ os swap class<= ] any? ] if-empty ;

: don't-load? ( vocab -- ? )
    {
        [ vocab-tags "not loaded" swap member? ]
        [ vocab-platforms supported-platform? not ]
    } 1|| ;

: filter-don't-load ( vocabs -- vocabs' )
    [ vocab-name don't-load? not ] filter ;

: don't-test? ( vocab -- ? )
    vocab-tags "not tested" swap member? ;

: filter-don't-test ( vocabs -- vocabs' )
    [ don't-test? not ] filter ;

TUPLE: unsupported-platform vocab requires ;

: unsupported-platform ( vocab requires -- )
    \ unsupported-platform boa throw-continue ;

M: unsupported-platform summary
    drop "Current operating system not supported by this vocabulary" ;

[
    dup vocab-platforms dup supported-platform?
    [ 2drop ] [ [ vocab-name ] dip unsupported-platform ] if
] check-vocab-hook set-global
