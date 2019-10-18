! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays definitions errors generic assocs
io kernel namespaces prettyprint prettyprint-internals
sequences words inspector ;

! Help articles
SYMBOL: articles

GENERIC: article-name ( article -- string )

TUPLE: article title content loc ;

M: article article-name article-title ;

TUPLE: no-article name ;
: no-article ( name -- * ) <no-article> throw ;

: article ( name -- article )
    dup articles get at [ ] [ no-article ] ?if ;

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

: related-words ( seq -- )
    dup [ swap "related" set-word-prop ] each-with ;

GENERIC: elements* ( elt-type element -- )

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- elements )
    [
        [
            swap elements [
                1 tail [ dup set ] each
            ] each
        ] each-with
    ] H{ } make-assoc keys ;

SYMBOL: help-tree

DEFER: $subsection

: children ( topic -- seq )
    article-content { $subsection } collect-elements ;

: parent ( topic -- topic )
    dup link? [ link-name ] when help-tree get at ;

: (help-path) ( topic -- )
    parent [ dup , (help-path) ] when* ;

: help-path ( topic -- seq )
    [ (help-path) ] { } make ;

: if-help-tree ( topic quot -- )
    help-tree get swap [ drop ] if ; inline

: xref-article ( topic -- )
    [
        dup children [ help-tree get set-at ] each-with
    ] if-help-tree ;

: unxref-article ( topic -- )
    [
        children [ help-tree get delete-at ] each
    ] if-help-tree ;
