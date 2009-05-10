! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs io.encodings.utf8 io.files
io.pathnames kernel make math.parser memoize sequences sets
sorting summary vocabs vocabs.loader ;
IN: vocabs.metadata

MEMO: vocab-file-contents ( vocab name -- seq )
    vocab-append-path dup
    [ dup exists? [ utf8 file-lines ] [ drop f ] if ] when ;

: set-vocab-file-contents ( seq vocab name -- )
    dupd vocab-append-path [
        utf8 set-file-lines
        \ vocab-file-contents reset-memoized
    ] [
        "The " swap vocab-name
        " vocabulary was not loaded from the file system"
        3append throw
    ] ?if ;

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
    [ vocab-tags append prune ] keep set-vocab-tags ;

: vocab-authors-path ( vocab -- string )
    vocab-dir "authors.txt" append-path ;

: vocab-authors ( vocab -- authors )
    dup vocab-authors-path vocab-file-contents harvest ;

: set-vocab-authors ( authors vocab -- )
    dup vocab-authors-path set-vocab-file-contents ;

: unportable? ( vocab -- ? )
    vocab-tags "unportable" swap member? ;