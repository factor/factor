! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays definitions errors generic graphs hashtables
inspector io kernel namespaces prettyprint sequences words ;

! Markup
GENERIC: print-element

! Help articles
SYMBOL: articles

TUPLE: article title content loc ;

TUPLE: no-article name ;
: no-article ( name -- * ) <no-article> throw ;

: article ( name -- article )
    dup articles get hash [ ] [ no-article ] ?if ;

M: object article-title article article-title ;
M: object article-content article article-content ;

TUPLE: link name ;

M: link article-title link-name article-title ;
M: link article-content link-name article-content ;
M: link summary "Link: " swap link-name unparse append ;

! Special case: f help
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

: children ( article -- seq )
    article-content { $subsection } collect-elements ;

: parents ( article -- seq )
    dup link? [ link-name ] when parent-graph get in-edges ;

: (doc-path) ( article -- )
    dup , parents [ word? not ] subset dup empty?
    [ drop ] [ [ (doc-path) ] each ] if ;

: doc-path ( article -- seq )
    [ (doc-path) ] { } make 1 tail prune ;

: xref-article ( article -- )
    [ children ] parent-graph get add-vertex ;

: unxref-article ( article -- )
    [ children ] parent-graph get remove-vertex ;

: xref-help ( -- )
    all-articles [ children ] parent-graph get build-graph ;

! Definition protocol
M: link where link-name article article-loc ;

M: link (synopsis)
    \ ARTICLE: pprint-word
    dup link-name pprint*
    article-title pprint* ;

M: link definition article-content t ;

M: link see (see) ;

PREDICATE: link word-link link-name word? ;

M: word-link where link-name "help-loc" word-prop ;

M: word-link (synopsis)
    \ HELP: pprint-word
    link-name dup pprint-word
    "stack-effect" word-prop pprint* ;

M: word-link definition
    link-name "help" word-prop t ;

M: word-link see (see) ;
