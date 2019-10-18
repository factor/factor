! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays generic graphs hashtables io kernel lists
namespaces sequences strings words ;

: all-articles ( -- seq )
    [
        articles get hash-keys %
        [ word-article ] word-subset %
        terms get hash-keys [ <term> ] map %
    ] { } make ;

: sort-articles ( seq -- assoc )
    [ [ article-title ] keep 2array ] map
    [ [ first ] 2apply <=> ] sort
    [ second ] map ;

: each-article ( quot -- ) all-articles swap each ; inline

GENERIC: elements* ( elt-type element -- )

M: simple-element elements* [ elements* ] each-with ;

M: object elements* 2drop ;

M: array elements*
    [ [ elements* ] each-with ] 2keep
    [ first eq? ] keep swap [ , ] [ drop ] if ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( elt-type article -- )
    elements [ 1 swap tail [ dup set ] each ] each ; inline

: links-out ( article -- seq )
    article-content [
        \ $link over collect-elements
        \ $see-also over collect-elements
        \ $subsection swap collect-elements
    ] make-hash hash-keys ;

SYMBOL: help-graph

: links-in ( article -- )
    dup link? [ link-name ] when help-graph get in-edges ;

: xref-article ( article -- )
    [ links-out ] help-graph get add-vertex ;

: unxref-article ( article -- )
    [ links-out ] help-graph get remove-vertex ;

: xref-articles ( -- )
    H{ } clone help-graph set
    all-articles [ links-out ] help-graph get add-vertices ;

: help-outliner ( seq quot -- | quot: obj -- )
    swap sort-articles [ ($subsection) terpri ] each-with ;

: articles. ( -- )
    articles get hash-keys [ help ] help-outliner ;

: links-out. ( article -- )
    links-out [ links-out. ] help-outliner ;

: links-in. ( article -- )
    links-in [ links-in. ] help-outliner ;
