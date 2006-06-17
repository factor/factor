! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays generic graphs hashtables io kernel
namespaces sequences strings words ;

: all-articles ( -- seq )
    [
        articles get hash-keys %
        [ word-article ] word-subset %
    ] { } make ;

GENERIC: elements* ( elt-type element -- )

M: simple-element elements* [ elements* ] each-with ;

M: object elements* 2drop ;

M: array elements*
    [ [ elements* ] each-with ] 2keep
    [ first eq? ] keep swap [ , ] [ drop ] if ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( elt-type article -- )
    elements [ 1 swap tail [ dup set ] each ] each ;

: links-out ( article -- seq )
    article-content [
        \ $link over collect-elements
        \ $see-also over collect-elements
        \ $subsection swap collect-elements
    ] make-hash hash-keys ;

SYMBOL: help-graph

: links-in ( article -- seq )
    dup link? [ link-name ] when help-graph get in-edges ;

: xref-article ( article -- )
    [ links-out ] help-graph get add-vertex ;

: unxref-article ( article -- )
    [ links-out ] help-graph get remove-vertex ;

: xref-articles ( -- )
    all-articles [ links-out ] help-graph get build-graph ;

: links-in. ( article -- )
    links-in [ links-in. ] help-outliner ;
