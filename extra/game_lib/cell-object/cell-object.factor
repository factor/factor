USING: accessors math kernel ;

IN: game_lib.cell-object 


TUPLE: cell-object draw-cell-delegate ;
    
GENERIC: draw-cell-object* ( loc dim delegate -- )

: <cell-object*> ( draw-delegate -- cell )
    cell-object boa ;

: <cell-object> ( delegate -- cell )
    <cell-object*> ; inline



TUPLE: flowcell-object < cell-object flow ;

! the flowcell will move every target frames
! counter keeps track of how many frames have passed since the flowcell has last moved
TUPLE: flow is-on direction target counter ;

! -------------------- Constructors ----------------------------------------
:: <flowcell-object*> ( draw-delegate -- flowcell-object )
    f f f f flow boa :> flow-obj
    f flow-obj flowcell-object boa 
    ;

: <flowcell-object> ( delegate -- flowcell-object )
    <flowcell-object*> ; inline

! -------------------- Helper methods ----------------------------------------
! Checks if the flow constant is at the specified location on the board
:: flow-on? ( flowcell-object -- ? )
    flowcell-object flow>> is-on>> ;

! Add flow information to the cell
:: set-flow ( flowcell-object direction target -- flowcell-object ) 
    t direction target 0 flow boa :> flow-obj
    flowcell-object flow-obj >>flow
    ;

:: turn-off-flow ( flowcell-object -- flowcell-object ) 
    f f f f flow boa :> flow-obj
    flowcell-object flow-obj >>flow
    ;