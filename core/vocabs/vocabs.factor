! Copyright (C) 2007 Eduardo Cavazos, Slava Pestov.
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

: create-vocab ( name -- vocab )
    dictionary get [ <vocab> ] cache
    t over set-vocab-source-loaded? ;

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
    [ vocab-words at ] curry* map
    [ ] subset ;

: forget-vocab ( vocab -- )
    dup vocab-words values forget-all
    vocab-name dictionary get delete-at ;

: child-vocab? ( prefix name -- ? )
    2dup = pick empty? or
    [ 2drop t ] [ swap CHAR: . add head? ] if ;

: child-vocabs ( vocab -- seq )
    vocab-name vocabs [ child-vocab? ] curry* subset ;

TUPLE: vocab-link name root ;

M: vocab-link vocab-name vocab-link-name ;

: >vocab-link ( name root -- vocab )
    over vocab dup
    [ 2nip ] [ drop \ vocab-link construct-boa ] if ;

UNION: vocab-spec vocab vocab-link ;

M: vocab-spec forget vocab-name forget-vocab ;
