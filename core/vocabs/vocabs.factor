! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs strings kernel sorting namespaces sequences
definitions ;
IN: vocabs

SYMBOL: dictionary

TUPLE: vocab
name root
words
main help
source-loaded? docs-loaded? ;

M: vocab equal? 2drop f ;

: <vocab> ( name -- vocab )
    H{ } clone t
    { set-vocab-name set-vocab-words set-vocab-source-loaded? }
    \ vocab construct ;

GENERIC: vocab ( vocab-spec -- vocab )

M: vocab vocab ;

M: object vocab ( name -- vocab ) vocab-name dictionary get at ;

M: string vocab-name ;

M: object vocab-words vocab vocab-words ;

M: object vocab-help vocab vocab-help ;

M: object vocab-main vocab vocab-main ;

M: object vocab-source-loaded?
    vocab vocab-source-loaded? ;

M: object set-vocab-source-loaded?
    vocab set-vocab-source-loaded? ;

M: object vocab-docs-loaded?
    vocab vocab-docs-loaded? ;

M: object set-vocab-docs-loaded?
    vocab set-vocab-docs-loaded? ;

M: f vocab-words ;

M: f vocab-source-loaded? ;

M: f set-vocab-source-loaded? 2drop ;

M: f vocab-docs-loaded? ;

M: f set-vocab-docs-loaded? 2drop ;

M: f vocab-help ;

: create-vocab ( name -- vocab )
    dictionary get [ <vocab> ] cache ;

SYMBOL: load-vocab-hook

: load-vocab ( name -- vocab ) load-vocab-hook get call ;

: vocabs ( -- seq )
    dictionary get keys natural-sort ;

: words ( vocab -- seq )
    vocab-words values ;

: all-words ( -- seq )
    dictionary get values [ words ] map concat ;

: words-named ( str -- seq )
    dictionary get values
    [ vocab-words at ] with map
    [ ] subset ;

: child-vocab? ( prefix name -- ? )
    2dup = pick empty? or
    [ 2drop t ] [ swap CHAR: . add head? ] if ;

: child-vocabs ( vocab -- seq )
    vocab-name vocabs [ child-vocab? ] with subset ;

TUPLE: vocab-link name root ;

: <vocab-link> ( name root -- vocab-link )
    [ dup vocab-root ] unless* vocab-link construct-boa ;

M: vocab-link equal?
    over vocab-link?
    [ [ vocab-link-name ] 2apply = ] [ 2drop f ] if ;

M: vocab-link hashcode*
    vocab-link-name hashcode* ;

M: vocab-link vocab-name vocab-link-name ;

GENERIC# >vocab-link 1 ( name root -- vocab )

M: vocab >vocab-link drop ;

M: vocab-link >vocab-link drop ;

M: string >vocab-link
    over vocab dup [ 2nip ] [ drop <vocab-link> ] if ;

UNION: vocab-spec vocab vocab-link ;

: forget-vocab ( vocab -- )
    dup words forget-all
    vocab-name dictionary get delete-at ;

M: vocab-spec forget* forget-vocab ;

TUPLE: no-vocab name ;

: no-vocab ( name -- * )
    vocab-name \ no-vocab construct-boa throw ;
