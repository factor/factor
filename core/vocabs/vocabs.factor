! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs strings kernel sorting namespaces sequences
definitions ;
IN: vocabs

SYMBOL: dictionary

TUPLE: vocab
name words
main help
source-loaded? docs-loaded? ;

M: vocab equal? 2drop f ;

: <vocab> ( name -- vocab )
    H{ } clone
    { set-vocab-name set-vocab-words }
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

TUPLE: no-vocab name ;

: no-vocab ( name -- * )
    vocab-name \ no-vocab construct-boa throw ;

SYMBOL: load-vocab-hook ! ( name -- )

: load-vocab ( name -- vocab )
    dup load-vocab-hook get call
    dup vocab [ ] [ no-vocab ] ?if ;

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

TUPLE: vocab-link name ;

: <vocab-link> ( name -- vocab-link )
    vocab-link construct-boa ;

M: vocab-link equal?
    over vocab-link?
    [ [ vocab-link-name ] 2apply = ] [ 2drop f ] if ;

M: vocab-link hashcode*
    vocab-link-name hashcode* ;

M: vocab-link vocab-name vocab-link-name ;

UNION: vocab-spec vocab vocab-link ;

GENERIC: >vocab-link ( name -- vocab )

M: vocab-spec >vocab-link ;

M: string >vocab-link dup vocab [ ] [ <vocab-link> ] ?if ;

: forget-vocab ( vocab -- )
    dup words forget-all
    vocab-name dictionary get delete-at ;

M: vocab-spec forget* forget-vocab ;
