USING: accessors math kernel ;

IN: game_lib.cell 

TUPLE: cell draw-cell-delegate ;
    

GENERIC: draw-cell* ( loc dim delegate -- )


: <cell*> ( draw-delegate -- cell )
    cell boa ;

: <cell> ( delegate -- cell )
    <cell*> ; inline