USING: accessors math kernel ;

IN: game_lib.cell 

TUPLE: flowcell draw-cell-delegate flow ;

! the flowcell will move every target frames
! counter keeps track of how many frames have passed since the flowcell has last moved
TUPLE: flow is-on direction target counter ;

GENERIC: draw-cell* ( loc dim delegate -- )

! -------------------- Constructors ----------------------------------------
:: <flowcell*> ( draw-delegate -- flowcell )
    f f f f flow boa :> flow-obj
    f flow-obj flowcell boa 
    ;

: <flowcell> ( delegate -- flowcell )
    <flowcell*> ; inline

! -------------------- Helper methods ----------------------------------------
! Checks if the flow constant is at the specified location on the board
:: flow-on? ( flowcell -- ? )
    flowcell flow>> is-on>> ;

! Add flow information to the cell
:: set-flow ( flowcell direction target -- flowcell ) 
    t direction target 0 flow boa :> flow-obj
    flowcell flow-obj >>flow
    ;

:: turn-off-flow ( cell -- cell ) 
    f f f f flow boa :> flow-obj
    flowcell flow-obj >>flow
    ;