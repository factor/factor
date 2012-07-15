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
    [ ".factor" append-vocab-dir append-path exists? ]
    [ 2drop f ]
    if ;

ERROR: vocab-root-required root ;

: ensure-vocab-root ( root -- root )
    dup vocab-roots get member? [ vocab-root-required ] unless ;

: ensure-vocab-root/prefix ( root prefix -- root prefix )
    [ ensure-vocab-root ] [ check-vocab-name ] bi* ;

: (child-vocabs) ( root prefix -- vocabs )
    check-vocab-name
    [ vocab-dir append-path dup exists? [ vocab-subdirs ] [ drop { } ] if ]
    [ nip [ "." append '[ _ prepend ] map! ] unless-empty ]
    [ drop '[ _ over vocab-dir? [ >vocab-link ] [ <vocab-prefix> ] if ] map! ]
    2tri ;

: ((child-vocabs-recursive)) ( root prefix -- )
    dupd vocab-name (child-vocabs) [ % ] keep
    [ ((child-vocabs-recursive)) ] with each ;

: (child-vocabs-recursive) ( root prefix -- seq )
    [ ensure-vocab-root ] dip
    [ ((child-vocabs-recursive)) ] { } make ;

: no-rooted ( seq -- seq' ) [ find-vocab-root not ] filter ;

: one-level-only? ( name prefix -- ? )
    ?head [ "." split1 nip not ] [ drop f ] if ;

: unrooted-child-vocabs ( prefix -- seq )
    [ vocabs no-rooted ] dip
    dup empty? [ CHAR: . suffix ] unless
    '[ vocab-name _ one-level-only? ] filter ;

: unrooted-child-vocabs-recursive ( prefix -- seq )
    vocabs:child-vocabs no-rooted ;

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

: filter-vocabs ( assoc -- seq )
    no-roots no-prefixes members ;

: child-vocabs ( prefix -- assoc )
    [ [ vocab-roots get ] dip '[ dup _ (child-vocabs) ] { } map>assoc ]
    [ unrooted-child-vocabs [ lookup-vocab ] map! f swap 2array ]
    bi suffix ;

: all-vocabs ( -- assoc )
    "" child-vocabs ;

: child-vocabs-recursive ( prefix -- assoc )
    [ [ vocab-roots get ] dip '[ dup _ (child-vocabs-recursive) ] { } map>assoc ]
    [ unrooted-child-vocabs-recursive [ lookup-vocab ] map! f swap 2array ]
    bi suffix ;

MEMO: all-vocabs-recursive ( -- assoc )
    "" child-vocabs-recursive ;

: all-vocab-names ( -- seq )
    all-vocabs-recursive filter-vocabs [ vocab-name ] map! ;

: child-vocab-names ( prefix -- seq )
    child-vocabs filter-vocabs [ vocab-name ] map! ;

<PRIVATE

: collect-vocabs ( quot -- seq )
    [ all-vocabs-recursive filter-vocabs ] dip
    gather natural-sort ; inline

: maybe-include-root/prefix ( root prefix -- vocab-link/f )
    over [
        [ find-vocab-root = ] keep swap
    ] [
        nip dup find-vocab-root
    ] if [ >vocab-link ] [ drop f ] if ;

PRIVATE>

: vocabs-in-root/prefix ( root prefix -- seq )
    [ (child-vocabs-recursive) ]
    [ maybe-include-root/prefix [ prefix ] when* ] 2bi ;

: vocabs-in-root ( root -- seq )
    "" vocabs-in-root/prefix ;

: (load-from-root) ( root prefix -- failures )
    vocabs-in-root/prefix
    [ don't-load? not ] filter no-prefixes
    require-all ;

: load-from-root ( root prefix -- )
    (load-from-root) load-failures. ;

: load-root ( root -- )
    "" load-from-root ;

: (load) ( prefix -- failures )
    [ vocab-roots get ] dip '[ _ (load-from-root) ] map concat ;

: load ( prefix -- )
    (load) load-failures. ;

: load-all ( -- )
    "" load ;

MEMO: all-tags ( -- seq ) [ vocab-tags ] collect-vocabs ;

MEMO: all-authors ( -- seq ) [ vocab-authors ] collect-vocabs ;
