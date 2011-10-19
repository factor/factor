! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit fry
io.directories io.files io.files.info io.pathnames kernel make
memoize namespaces sequences sorting splitting vocabs sets
vocabs.loader vocabs.metadata vocabs.errors continuations
strings ;
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

: trim-prefix ( prefix -- prefix' )
    [ ".\\/" member? ] trim-tail ;

PRIVATE>

: no-prefixes ( seq -- seq' ) [ vocab-prefix? not ] filter ;

: convert-prefixes ( seq -- seq' )
    [ dup vocab-prefix? [ name>> vocab-link boa ] when ] map ;

: remove-redundant-prefixes ( seq -- seq' )
    #! Hack.
    [ vocab-prefix? ] partition
    [
        [ vocab-name ] map fast-set
        '[ name>> _ in? not ] filter
        convert-prefixes
    ] keep
    append ;

: no-roots ( assoc -- seq ) values concat ;

: child-vocabs ( prefix -- assoc )
    trim-prefix
    [ [ vocab-roots get ] dip '[ dup _ (child-vocabs) ] { } map>assoc ]
    [ unrooted-child-vocabs [ vocab ] map f swap 2array ]
    bi suffix ;

: all-vocabs ( -- assoc )
    "" child-vocabs ;

: child-vocabs-recursive ( prefix -- assoc )
    trim-prefix
    [ [ vocab-roots get ] dip '[ dup _ (child-vocabs-recursive) ] { } map>assoc ]
    [ unrooted-child-vocabs-recursive [ vocab ] map f swap 2array ]
    bi suffix ;

MEMO: all-vocabs-recursive ( -- assoc )
    "" child-vocabs-recursive ;

<PRIVATE

: fixup-vocab-links ( seq -- seq' )
    no-roots no-prefixes members ;

: collect-vocabs ( quot -- seq )
    [ all-vocabs-recursive fixup-vocab-links ] dip
    gather natural-sort ; inline

PRIVATE>

: all-vocab-names ( -- seq )
    all-vocabs-recursive fixup-vocab-links
    [ normalized-vocab-name ] map ;

: child-vocab-names ( prefix -- seq )
    child-vocabs fixup-vocab-links
    [ normalized-vocab-name ] map ;

: vocabs-from ( prefix -- seq )
    [ child-vocabs-recursive fixup-vocab-links ]
    [ dup find-vocab-root [ >vocab-link prefix ] [ drop ] if ] bi
    filter-don't-load
    [ normalized-vocab-name ] map ;

: (load) ( prefix -- failures )
    vocabs-from require-all ;

: load ( prefix -- )
    (load) load-failures. ;

: load-all ( -- )
    "" load ;

: loaded-vocabs-from ( vocabulary-root -- seq )
    vocabs [
        swap '[ _ find-vocab-root _ head? ] [ drop f ] recover
    ] with filter sift ;

: unloaded-vocabs-from ( vocabulary-root -- seq )
    [ vocabs-from ] [ loaded-vocabs-from ] bi diff ;

MEMO: all-tags ( -- seq ) [ vocab-tags ] collect-vocabs ;

MEMO: all-authors ( -- seq ) [ vocab-authors ] collect-vocabs ;
