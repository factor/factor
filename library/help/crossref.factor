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

: collect-elements ( element seq -- elements )
    [
        [
            swap elements [
                1 swap tail [ dup set ] each
            ] each
        ] each-with
    ] make-hash hash-keys ;

SYMBOL: parent-graph

DEFER: $subsection

: children ( article -- seq )
    article-content { $subsection } collect-elements ;

: parents ( article -- seq )
    dup link? [ link-name ] when parent-graph get in-edges ;

: (where) ( article -- )
    dup , parents [ word? not ] subset dup empty?
    [ drop ] [ [ (where) ] each ] if ;

: where ( article -- seq )
    [ (where) ] { } make 1 swap tail prune ;

: $where ( article -- )
    where dup empty? [
        drop
    ] [
        [
            where-style [
                "Parent topics: " write $links
            ] with-style
        ] ($block)
    ] if ;

: xref-article ( article -- )
    [ children ] parent-graph get add-vertex ;

: unxref-article ( article -- )
    [ children ] parent-graph get remove-vertex ;

: xref-articles ( -- )
    all-articles [ children ] parent-graph get build-graph ;
