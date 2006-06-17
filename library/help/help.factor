! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays errors hashtables io kernel namespaces sequences
strings ;

! Markup
GENERIC: print-element

DEFER: $title

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

: print-title ( article -- )
    article-title $title ;

: with-default-style ( quot -- )
    default-char-style [
        default-para-style [ last-block on call ] with-nesting
    ] with-style ; inline

: print-content ( element -- )
    [ print-element ] with-default-style ;

: (help) ( topic -- ) article-content print-content terpri ;

: help ( topic -- ) dup print-title (help) ;

: handbook ( -- ) "handbook" help ;
