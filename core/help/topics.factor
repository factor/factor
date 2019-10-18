! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays definitions errors generic graphs hashtables
io kernel namespaces prettyprint prettyprint-internals
sequences words ;

! Help articles
SYMBOL: articles

GENERIC: article-name ( article -- string )

TUPLE: article title content loc ;

M: article article-name article-title ;

TUPLE: no-article name ;
: no-article ( name -- * ) <no-article> throw ;

: article ( name -- article )
    dup articles get hash [ ] [ no-article ] ?if ;

M: object article-name article article-name ;
M: object article-title article article-title ;
M: object article-content article article-content ;

TUPLE: link name ;

M: link article-name link-name article-name ;
M: link article-title link-name article-title ;
M: link article-content link-name article-content ;

M: link summary
    [
        "Link: " %
        link-name dup word? [ summary ] [ unparse ] if %
    ] "" make ;

! Special case: f help
M: f article-name drop \ f article-name ;
M: f article-title drop \ f article-title ;
M: f article-content drop \ f article-content ;

: word-help ( word -- content ) "help" word-prop ;

: all-articles ( -- seq )
    articles get hash-keys
    all-words [ word-help ] subset append ;

GENERIC: elements* ( elt-type element -- )

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    [
        [
            swap elements [
                1 tail [ dup set ] each
            ] each
        ] each-with
    ] make-hash hash-keys ;

SYMBOL: parent-graph

DEFER: $subsection

: children ( topic -- seq )
    article-content { $subsection } collect-elements ;

: parents ( topic -- seq )
    dup link? [
        link-name parents
    ] [
        parent-graph get in-edges
    ] if ;

: (doc-path) ( topic -- )
    dup , parents [ word? not ] subset dup empty?
    [ drop ] [ [ (doc-path) ] each ] if ;

: doc-path ( topic -- seq )
    [ (doc-path) ] { } make 1 tail prune ;

: xref-article ( topic -- )
    [ children ] parent-graph get add-vertex ;

: unxref-article ( topic -- )
    [ children ] parent-graph get remove-vertex ;

: xref-help ( -- )
    all-articles [ children ] parent-graph get build-graph ;
