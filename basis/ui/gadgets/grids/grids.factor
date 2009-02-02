! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math namespaces make sequences words io
math.vectors ui.gadgets columns accessors strings.tables
math.geometry.rect locals fry ;
IN: ui.gadgets.grids

TUPLE: grid < gadget
grid
{ gap initial: { 0 0 } }
{ fill? initial: t } ;

: new-grid ( children class -- grid )
    new-gadget
        swap >>grid
        dup grid>> concat add-gadgets ; inline

: <grid> ( children -- grid )
    grid new-grid ;

:: grid-child ( grid i j -- gadget ) i j grid grid>> nth nth ;

:: grid-add ( grid child i j -- grid )
    grid i j grid-child unparent
    grid child add-gadget
    child i j grid grid>> nth set-nth ;

: grid-remove ( grid i j -- grid ) [ <gadget> ] 2dip grid-add ;

: pref-dim-grid ( grid -- dims )
    grid>> [ [ pref-dim ] map ] map ;

: (compute-grid) ( grid -- seq ) [ max-dim ] map ;

: compute-grid ( grid -- horiz vert )
    pref-dim-grid [ flip (compute-grid) ] [ (compute-grid) ] bi ;

: (pair-up) ( horiz vert -- dim )
    [ first ] [ second ] bi* 2array ;

: pair-up ( horiz vert -- dims )
    [ [ (pair-up) ] curry map ] with map ;

: add-gaps ( gap seq -- newseq )
    [ v+ ] with map ;

: gap-sum ( gap seq -- newseq )
    dupd add-gaps dim-sum v+ ;

M: grid pref-dim*
    [ gap>> ] [ compute-grid ] bi
    [ over ] dip [ gap-sum ] 2bi@ (pair-up) ;

: do-grid ( dims grid quot -- )
    [ grid>> ] dip '[ _ 2each ] 2each ; inline

: grid-positions ( grid dims -- locs )
    [ gap>> dup ] dip add-gaps swap [ v+ ] accumulate nip ;

: position-grid ( grid horiz vert -- )
    pick [ [ over ] dip [ grid-positions ] 2bi@ pair-up ] dip
    [ (>>loc) ] do-grid ;

: resize-grid ( grid horiz vert -- )
    pick fill?>> [
        pair-up swap [ (>>dim) ] do-grid
    ] [
        2drop grid>> [ [ prefer ] each ] each
    ] if ;

: grid-layout ( grid horiz vert -- )
    [ position-grid ] 3keep resize-grid ;

M: grid layout* dup compute-grid grid-layout ;

M: grid children-on ( rect gadget -- seq )
    dup children>> empty?
      [ 2drop f ]
      [
        { 0 1 } swap grid>>
        [ 0 <column> fast-children-on ] keep
        <slice> concat
      ]
    if ;

M: grid gadget-text*
    grid>>
    [ [ gadget-text ] map ] map format-table
    [ CHAR: \n , ] [ % ] interleave ;
