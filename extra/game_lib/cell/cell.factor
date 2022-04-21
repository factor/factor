USING: accessors math kernel sequences ;

IN: game_lib.cell 

TUPLE: cell draw-cell-delegate ;
    

GENERIC: draw-cell* ( loc dim delegate -- )


: <cell*> ( draw-delegate -- cell )
    cell boa ;

: <cell> ( delegate -- cell )
    <cell*> ; inline


TUPLE: child-cell < cell parent ;


GENERIC: call-parent* ( instruction delegate -- )

TUPLE: parent children function ;

: <parent*> ( children function -- parent )
    parent boa ;

: <parent> ( children function -- parent )
    <parent*> ; inline

:: new-child ( child-pos parent -- )
    parent parent children>> { child-pos } append >>children drop ;