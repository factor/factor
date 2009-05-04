! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators.short-circuit fry
io.directories io.files io.files.info io.pathnames kernel make
memoize namespaces sequences sorting splitting vocabs sets
vocabs.loader vocabs.metadata vocabs.errors ;
IN: vocabs.hierarchy

<PRIVATE

: vocab-subdirs ( dir -- dirs )
    [
        [
            { [ link-info directory? ] [ "." head? not ] } 1&&
        ] filter
    ] with-directory-files natural-sort ;

: (all-child-vocabs) ( root name -- vocabs )
    [
        vocab-dir append-path dup exists?
        [ vocab-subdirs ] [ drop { } ] if
    ] keep
    [ '[ [ _ "." ] dip 3append ] map ] unless-empty ;

: vocab-dir? ( root name -- ? )
    over
    [ ".factor" vocab-dir+ append-path exists? ]
    [ 2drop f ]
    if ;

: vocabs-in-dir ( root name -- )
    dupd (all-child-vocabs) [
        2dup vocab-dir? [ dup >vocab-link , ] when
        vocabs-in-dir
    ] with each ;

PRIVATE>

: all-vocabs ( -- assoc )
    vocab-roots get [
        dup [ "" vocabs-in-dir ] { } make
    ] { } map>assoc ;

: all-vocabs-under ( prefix -- vocabs )
    [
        [ vocab-roots get ] dip '[ _ vocabs-in-dir ] each
    ] { } make ;

MEMO: all-vocabs-seq ( -- seq )
    "" all-vocabs-under ;

<PRIVATE

: unrooted-child-vocabs ( prefix -- seq )
    dup empty? [ CHAR: . suffix ] unless
    vocabs
    [ find-vocab-root not ] filter
    [
        vocab-name swap ?head CHAR: . rot member? not and
    ] with filter
    [ vocab ] map ;

PRIVATE>

: all-child-vocabs ( prefix -- assoc )
    vocab-roots get [
        dup pick (all-child-vocabs) [ >vocab-link ] map
    ] { } map>assoc
    swap unrooted-child-vocabs f swap 2array suffix ;

: all-child-vocabs-seq ( prefix -- assoc )
    vocab-roots get swap '[
        dup _ (all-child-vocabs)
        [ vocab-dir? ] with filter
    ] map concat ;

<PRIVATE

: filter-unportable ( seq -- seq' )
    [ vocab-name unportable? not ] filter ;

PRIVATE>

: (load) ( prefix -- failures )
    all-vocabs-under
    filter-unportable
    require-all ;

: load ( prefix -- )
    (load) load-failures. ;

: load-all ( -- )
    "" load ;

MEMO: all-tags ( -- seq )
    all-vocabs-seq [ vocab-tags ] gather natural-sort ;

MEMO: all-authors ( -- seq )
    all-vocabs-seq [ vocab-authors ] gather natural-sort ;