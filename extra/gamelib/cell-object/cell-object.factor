USING: accessors math kernel sequences math.vectors gamelib.board ;

IN: gamelib.cell-object 

TUPLE: cell-object draw-cell-delegate ;
    
GENERIC: draw-cell-object* ( loc dim delegate -- )

: <cell-object*> ( draw-delegate -- cell )
    cell-object boa ;

: <cell-object> ( delegate -- cell )
    <cell-object*> ; inline


TUPLE: flowcell-object < cell-object flow ;

! the flowcell-object will move every target frames
! counter keeps track of how many frames have passed since the flowcell-object has last moved
TUPLE: flow is-on direction target counter ;

! -------------------- Helper methods ----------------------------------------
! Checks if the flow constant is at the specified location on the board
:: flow-on? ( flowcell-object -- ? )
    flowcell-object flow>> is-on>> ;

! Add flow information to the cell
:: set-flow ( flowcell-object direction target -- flowcell-object ) 
    t direction target 0 flow boa :> flow-obj
    flowcell-object flow-obj >>flow
    ;

:: turn-off-flow ( cell -- cell ) 
    f f f f flow boa :> flow-obj
    flowcell-object flow-obj >>flow
    ;


TUPLE: child-cell < cell-object parent ;


GENERIC: call-parent* ( resources instruction delegate -- )

TUPLE: parent children function ;

: <parent*> ( children function -- parent )
    parent boa ;

: <parent> ( children function -- parent )
    <parent*> ; inline

:: new-child ( child-pos parent -- )
    parent parent children>> { child-pos } append >>children drop ;

:: fill-board-parent ( board parent -- board )
    board parent children>> { parent } set-cells ;

:: move-children ( board move parent -- board )
    parent children>> :> children
    parent children [ move v+ ] map >>children drop
    board children children [ move v+ ] map board children first get-cell move-many-objects ;
