! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays generic graphs hashtables io kernel
namespaces sequences strings words ;

: all-articles ( -- seq )
    articles get hash-keys all-words append ;

GENERIC: elements* ( elt-type element -- )

M: simple-element elements* [ elements* ] each-with ;

M: object elements* 2drop ;

M: array elements*
    [ [ elements* ] each-with ] 2keep
    [ first eq? ] keep swap [ , ] [ drop ] if ;

: elements ( elt-type element -- seq ) [ elements* ] { } make ;

: collect-elements ( element seq -- )
    [
        [
            swap elements [
                1 swap tail [ dup set ] each
            ] each
        ] each-with
    ] make-hash hash-keys ;

SYMBOL: link-graph

: links-out ( article -- seq )
    article-content { $link $see-also } collect-elements ;

: ?link dup link? [ link-name ] when ;

: links-in ( article -- seq )
    ?link link-graph get in-edges ;

SYMBOL: parent-graph

: children ( article -- seq )
    article-content { $subsection } collect-elements ;

: ?link dup link? [ link-name ] when ;

: parents ( article -- seq )
    ?link parent-graph get in-edges ;

: (where) ( article -- )
    dup , parents [ word? not ] subset dup empty?
    [ drop ] [ [ (where) ] each ] if ;

: where ( article -- seq )
    [ (where) ] { } make 1 swap tail ;

: xref-article ( article -- )
    dup
    [ links-out ] link-graph get add-vertex
    [ children ] parent-graph get add-vertex ;

: unxref-article ( article -- )
    dup [ links-out ] link-graph get remove-vertex
    [ children ] parent-graph get remove-vertex ;

: xref-articles ( -- )
    all-articles dup
    [ links-out ] link-graph get build-graph
    [ children ] parent-graph get build-graph ;

: links-in. ( article -- )
    links-in [ links-in. ] help-outliner ;
