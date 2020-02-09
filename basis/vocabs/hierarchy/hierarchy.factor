! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit fry
io.directories io.files io.files.info io.pathnames kernel make
memoize namespaces sequences sets sorting splitting vocabs
vocabs.loader vocabs.metadata ;
IN: vocabs.hierarchy

TUPLE: vocab-prefix name ;

C: <vocab-prefix> vocab-prefix

M: vocab-prefix vocab-name name>> ;

<PRIVATE

: visible-dir? ( entry -- ? )
    { [ directory? ] [ name>> "." head? not ] } 1&& ;

: visible-dirs ( seq -- seq' )
    [ visible-dir? ] filter [ name>> ] sort-with ;

ERROR: vocab-root-required root ;

: ensure-vocab-root ( root -- root )
    dup vocab-roots get member? [ vocab-root-required ] unless ;

: ensure-vocab-root/prefix ( root prefix -- root prefix )
    [ ensure-vocab-root ] [ check-vocab-name ] bi* ;

: vocab-directory-entries ( root prefix -- vocab-path vocab-name entries )
    [ ensure-vocab-root ] dip [ append-path ] keep
    over dup exists? [ directory-entries ] [ drop { } ] if ;

: (disk-vocabs) ( root prefix -- seq )
    vocab-directory-entries visible-dirs [
        name>>
        [ dup ".factor" append append-path append-path ]
        [ over empty? [ nip ] [ "." glue ] if ] bi-curry bi*
        swap exists? [ >vocab-link ] [ <vocab-prefix> ] if
    ] 2with map ;

DEFER: add-vocab%

: add-vocab-children% ( vocab-path vocab-name entries -- )
    visible-dirs [
        name>>
        [ append-path ]
        [ over empty? [ nip ] [ "." glue ] if ] bi-curry bi*
        over directory-entries add-vocab%
    ] 2with each ;

: add-vocab% ( vocab-path vocab-name entries -- )
    3dup rot file-name ".factor" append '[ name>> _ =  ] any?
    [ >vocab-link ] [ <vocab-prefix> ] if , add-vocab-children% ;

: (disk-vocabs-recursive) ( root prefix -- seq )
    vocab-directory-entries
    [ add-vocab-children% ] { } make ;

: no-rooted ( seq -- seq' ) [ find-vocab-root ] reject ;

: one-level-only? ( name prefix -- ? )
    ?head [ "." split1 nip not ] [ drop f ] if ;

: unrooted-disk-vocabs ( prefix -- seq )
    [ loaded-vocab-names no-rooted ] dip
    dup empty? [ CHAR: . suffix ] unless
    '[ vocab-name _ one-level-only? ] filter ;

: unrooted-disk-vocabs-recursive ( prefix -- seq )
    loaded-child-vocab-names no-rooted ;

PRIVATE>

: no-prefixes ( seq -- seq' ) [ vocab-prefix? ] reject ;

: no-roots ( assoc -- seq ) values concat ;

: filter-vocabs ( assoc -- seq )
    no-roots no-prefixes members ;

: disk-vocabs-for-prefix ( prefix -- assoc )
    [ [ vocab-roots get ] dip '[ dup _ (disk-vocabs) ] { } map>assoc ]
    [ unrooted-disk-vocabs [ lookup-vocab ] map! f swap 2array ]
    bi suffix ;

: all-disk-vocabs-by-root ( -- assoc )
    "" disk-vocabs-for-prefix ;

: disk-vocabs-recursive-for-prefix ( prefix -- assoc )
    [ [ vocab-roots get ] dip '[ dup _ (disk-vocabs-recursive) ] { } map>assoc ]
    [ unrooted-disk-vocabs-recursive [ lookup-vocab ] map! f swap 2array ]
    bi suffix ;

MEMO: all-disk-vocabs-recursive ( -- assoc )
    "" disk-vocabs-recursive-for-prefix ;

: all-disk-vocab-names ( -- seq )
    all-disk-vocabs-recursive filter-vocabs [ vocab-name ] map! ;

: disk-child-vocab-names ( prefix -- seq )
    disk-vocabs-for-prefix filter-vocabs [ vocab-name ] map! ;

<PRIVATE

: collect-vocabs ( quot -- seq )
    [ all-disk-vocabs-recursive filter-vocabs ] dip
    gather natural-sort ; inline

: maybe-include-root/prefix ( root prefix -- vocab-link/f )
    over [
        [ find-vocab-root = ] keep swap
    ] [
        nip dup find-vocab-root
    ] if [ >vocab-link ] [ drop f ] if ;

PRIVATE>

: disk-vocabs-in-root/prefix ( root prefix -- seq )
    [ (disk-vocabs-recursive) ]
    [ maybe-include-root/prefix [ prefix ] when* ] 2bi ;

: disk-vocabs-in-root ( root -- seq )
    "" disk-vocabs-in-root/prefix ;

<PRIVATE

: vocabs-to-load ( root prefix -- seq )
    disk-vocabs-in-root/prefix
    [ don't-load? ] reject no-prefixes ;

PRIVATE>

: load-from-root ( root prefix -- )
    vocabs-to-load require-all ;

: load-root ( root -- )
    "" load-from-root ;

: load ( prefix -- )
    [ vocab-roots get ] dip '[ _ load-from-root ] each ;

: load-all ( -- )
    "" load ;

MEMO: all-tags ( -- seq )
    [ vocab-tags ] collect-vocabs ;

MEMO: all-authors ( -- seq )
    [ vocab-authors ] collect-vocabs ;
