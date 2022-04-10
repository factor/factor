USING: accessors math kernel ;

IN: game_lib.cell 

TUPLE: flowcell draw-cell-delegate flow ;

! the flowcell will move every target frames
! counter keeps track of how many frames have passed since last move
TUPLE: flow is-on direction target counter ;

GENERIC: draw-cell* ( loc dim delegate -- )


:: <flowcell*> ( draw-delegate -- flowcell )
    f f f f flow boa :> flow-obj
    f flow-obj flowcell boa 
    ;

: <flowcell> ( delegate -- flowcell )
    <flowcell*> ; inline


! --------------------- Flow ---------------------------------------------------------------------------------

! Checks if the flow constant is at the specified location on the board
:: flow-on? ( flowcell -- ? )
    flowcell flow>> is-on>> ;

! Add the flow constant to the specified location on the board if it isn't there yet
:: turn-on-flow ( flowcell direction target -- flowcell ) 
    t direction target 0 flow boa :> flow-obj
    flowcell flow-obj >>flow
    ;

:: turn-off-flow ( cell -- cell ) 
    f f f f flow boa :> flow-obj
    flowcell flow-obj >>flow
    ;

! turn on flow for flowcell, move objects by flow in loop library; user sets how fast flow is working as a percentage of game loop speed- using counter


