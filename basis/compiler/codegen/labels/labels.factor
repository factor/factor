! Copyright (C) 2007, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.codegen.relocation
compiler.constants kernel make math namespaces sequences ;
IN: compiler.codegen.labels

! Labels
SYMBOL: label-table

TUPLE: label offset ;

: <label> ( -- label ) label new ;
: define-label ( name -- ) <label> swap set ;

: resolve-label ( label/name -- )
    dup label? [ get ] unless
    compiled-offset >>offset drop ;

TUPLE: label-fixup-state { label label } { class integer } { offset integer } ;

: label-fixup ( label class -- )
    compiled-offset \ label-fixup-state boa label-table get push ;

: compute-target ( label-fixup -- offset )
    label>> offset>> [ "Unresolved label" throw ] unless* ;

: compute-relative-label ( label-fixup -- label )
    [ class>> ] [ offset>> ] [ compute-target ] tri 3array ;

: compute-absolute-label ( label-fixup -- )
    [ compute-target neg add-literal ]
    [ [ class>> rt-here ] [ offset>> ] bi add-relocation-at ] bi ;

: compute-labels ( label-fixups -- labels' )
    [ class>> rc-absolute? ] partition
    [ [ compute-absolute-label ] each ]
    [ [ compute-relative-label ] map concat ]
    bi* ;

SYMBOL: binary-literal-table

: add-binary-literal ( obj -- label )
    <label> [ 2array binary-literal-table get push ] keep ;

: rel-binary-literal ( literal class -- )
    [ add-binary-literal ] dip label-fixup ;

: emit-data ( obj label -- )
    over length align-code resolve-label % ;

: emit-binary-literals ( -- )
    binary-literal-table get [ emit-data ] assoc-each ;
