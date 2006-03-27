! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
USING: arrays hashtables io kernel namespaces parser sequences
strings styles words ;

! Markup
GENERIC: print-element

! Help articles
SYMBOL: articles

TUPLE: article title content ;

: article ( name -- article ) articles get hash ;

: add-article ( name title element -- )
    <article> swap articles get set-hash ;

M: string article-title article article-title ;

M: string article-content article article-content ;

! Special case: f help
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;

! Glossary of terms
SYMBOL: terms

TUPLE: term entry ;

M: term article-title term-entry ;

M: term article-content
    term-entry terms get hash
    [ "No such glossary entry" ] unless* ;

: add-term ( term element -- ) swap terms get set-hash ;
