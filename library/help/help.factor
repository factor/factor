! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays errors hashtables io kernel namespaces sequences
strings ;

! Markup
GENERIC: print-element

! Help articles
SYMBOL: articles

TUPLE: article title content ;

: article ( name -- article )
    dup articles get hash
    [ ] [ "No such article: " swap append throw ] ?if ;

: add-article ( name title element -- )
    <article> swap articles get set-hash ;

M: string article-title article article-title ;
M: string article-content article article-content ;

! Special case: f help
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;

SYMBOL: last-block

: (help) ( element -- )
    default-style [
        last-block on print-element
    ] with-nesting* terpri ;

: help ( topic -- ) article-content (help) ;

: handbook ( -- ) "handbook" help ;
