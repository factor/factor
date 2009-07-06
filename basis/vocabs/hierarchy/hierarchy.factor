! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit fry
io.directories io.files io.files.info io.pathnames kernel make
memoize namespaces sequences sorting splitting vocabs sets
vocabs.loader vocabs.metadata vocabs.errors ;
RENAME: child-vocabs vocabs => vocabs:child-vocabs
IN: vocabs.hierarchy

TUPLE: vocab-prefix name ;

C: <vocab-prefix> vocab-prefix

M: vocab-prefix vocab-name name>> ;

<PRIVATE

: vocab-subdirs ( dir -- dirs )
    [
        [
            { [ link-info directory? ] [ "." head? not ] } 1&&
        ] filter
    ] with-directory-files natural-sort ;

: vocab-dir? ( root name -- ? )
    over
    [ ".factor" vocab-dir+ append-path exists? ]
    [ 2drop f ]
    if ;

: (child-vocabs) ( root prefix -- vocabs )
    [ vocab-dir append-path dup exists? [ vocab-subdirs ] [ drop { } ] if ]
    [ nip [ '[ [ _ "." ] dip 3append ] map ] unless-empty ]
    [ drop '[ _ over vocab-dir? [ >vocab-link ] [ <vocab-prefix> ] if ] map ]
    2tri ;

: ((child-vocabs-recursive)) ( root name -- )
    dupd vocab-name (child-vocabs)
    [ dup , ((child-vocabs-recursive)) ] with each ;

: (child-vocabs-recursive) ( root name -- seq )
    [ ((child-vocabs-recursive)) ] { } make ;

: no-rooted ( seq -- seq' ) [ find-vocab-root not ] filter ;

: one-level-only? ( name prefix -- ? )
    ?head [ "." split1 nip not ] dip and ;

: unrooted-child-vocabs ( prefix -- seq )
    [ vocabs no-rooted ] dip
    dup empty? [ CHAR: . suffix ] unless
    '[ vocab-name _ one-level-only? ] filter ;

: unrooted-child-vocabs-recursive ( prefix -- seq )
    vocabs:child-vocabs no-rooted ;

PRIVATE>

: no-prefixes ( seq -- seq' ) [ vocab-prefix? not ] filter ;

: no-roots ( assoc -- seq ) values concat ;

: child-vocabs ( prefix -- assoc )
    [ [ vocab-roots get ] dip '[ dup _ (child-vocabs) ] { } map>assoc ]
    [ unrooted-child-vocabs [ vocab ] map f swap 2array ]
    bi suffix ;

: all-vocabs ( -- assoc )
    "" child-vocabs ;

: child-vocabs-recursive ( prefix -- assoc )
    [ [ vocab-roots get ] dip '[ dup _ (child-vocabs-recursive) ] { } map>assoc ]
    [ unrooted-child-vocabs-recursive [ vocab ] map f swap 2array ]
    bi suffix ;

MEMO: all-vocabs-recursive ( -- assoc )
    "" child-vocabs-recursive ;

: all-vocab-names ( -- seq )
    all-vocabs-recursive no-roots no-prefixes [ vocab-name ] map ;

<PRIVATE

: filter-unportable ( seq -- seq' )
    [ vocab-name unportable? not ] filter ;

: collect-vocabs ( quot -- seq )
    [ all-vocabs-recursive no-roots no-prefixes ] dip
    gather natural-sort ; inline

PRIVATE>

: (load) ( prefix -- failures )
    child-vocabs-recursive
    filter-unportable
    require-all ;

: load ( prefix -- )
    (load) load-failures. ;

: load-all ( -- )
    "" load ;

MEMO: all-tags ( -- seq ) [ vocab-tags ] collect-vocabs ;

MEMO: all-authors ( -- seq ) [ vocab-authors ] collect-vocabs ;
