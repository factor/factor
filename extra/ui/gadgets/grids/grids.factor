! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math namespaces sequences words io
io.streams.string math.vectors ui.gadgets columns accessors
math.geometry.rect ;
IN: ui.gadgets.grids

TUPLE: grid < gadget
grid
{ gap initial: { 0 0 } }
{ fill? initial: t } ;

: new-grid ( children class -- grid )
    new-gadget
    [ (>>grid) ] [ >r concat r> add-gadgets ] [ nip ] 2tri ;
    inline

: <grid> ( children -- grid )
    grid new-grid ;

: grid-child ( grid i j -- gadget ) rot grid>> nth nth ;

: grid-add ( gadget grid i j -- )
    >r >r 2dup add-gadget r> r>
    3dup grid-child unparent rot grid>> nth set-nth ;

: grid-remove ( grid i j -- )
    >r >r >r <gadget> r> r> r> grid-add ;

: pref-dim-grid ( grid -- dims )
    grid>> [ [ pref-dim ] map ] map ;

: (compute-grid) ( grid -- seq ) [ max-dim ] map ;

: compute-grid ( grid -- horiz vert )
    pref-dim-grid dup flip (compute-grid) swap (compute-grid) ;

: (pair-up) ( horiz vert -- dim )
    >r first r> second 2array ;

: pair-up ( horiz vert -- dims )
    [ [ (pair-up) ] curry map ] with map ;

: add-gaps ( gap seq -- newseq )
    [ v+ ] with map ;

: gap-sum ( gap seq -- newseq )
    dupd add-gaps dim-sum v+ ;

M: grid pref-dim*
    dup grid-gap swap compute-grid >r over r>
    gap-sum >r gap-sum r> (pair-up) ;

: do-grid ( dims grid quot -- )
    -rot grid>>
    [ [ pick call ] 2each ] 2each
    drop ; inline

: grid-positions ( grid dims -- locs )
    >r grid-gap dup r> add-gaps swap [ v+ ] accumulate nip ;

: position-grid ( grid horiz vert -- )
    pick >r
    >r over r> grid-positions >r grid-positions r>
    pair-up r> [ set-rect-loc ] do-grid ;

: resize-grid ( grid horiz vert -- )
    pick grid-fill? [
        pair-up swap [ set-layout-dim ] do-grid
    ] [
        2drop grid>> [ [ prefer ] each ] each
    ] if ;

: grid-layout ( grid horiz vert -- )
    [ position-grid ] 3keep resize-grid ;

M: grid layout* dup compute-grid grid-layout ;

M: grid children-on ( rect gadget -- seq )
    dup gadget-children empty? [
        2drop f
    ] [
        { 0 1 } swap grid>>
        [ 0 <column> fast-children-on ] keep
        <slice> concat
    ] if ;

M: grid gadget-text*
    grid>>
    [ [ gadget-text ] map ] map format-table
    [ CHAR: \n , ] [ % ] interleave ;
