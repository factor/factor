! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: help
USING: arrays hashtables io kernel namespaces parser sequences
strings styles words ;

! Markup
SYMBOL: style-stack

GENERIC: print-element

: with-style ( style quot -- )
    swap style-stack get push call style-stack get pop* ; inline

: current-style ( -- style )
    H{ } clone style-stack get [ dupd hash-update ] each ;

PREDICATE: array simple-element
    dup empty? [ drop t ] [ first word? not ] if ;

M: string print-element current-style format ;

M: simple-element print-element [ print-element ] each ;

M: array print-element
    dup first >r 1 swap tail r> execute ;

: default-style H{ { font "Sans Serif" } { font-size 14 } } ;

: with-markup ( quot -- )
    [
        default-style V{ } clone [ push ] keep style-stack set
        call
    ] with-scope ; inline

! Help articles
SYMBOL: articles

TUPLE: article title content ;

: article ( name -- article ) articles get hash ;

: add-article ( name title element -- )
    <article> swap articles get set-hash ;

M: string article-title article article-title ;

M: string article-content article article-content ;

! Word help
M: word article-title "The " swap word-name " word" append3 ;

M: word article-content
    dup "help" word-prop [ ] [
        "No documentation found for " swap word-name append
    ] ?if ;

! Glossary of terms
SYMBOL: terms

TUPLE: term entry ;

M: term article-title term-entry ;

M: term article-content terms get hash ;
