USING: generic kernel namespaces prettyprint sql sql:utils ;
IN: sqlite

TUPLE: sqlite ;
C: sqlite ( path -- db )
    >r sqlite-open <connection> r>
    [ set-delegate ] keep ;

! M: sqlite insert-sql* ( tuple db -- string )
    #! Insert and fill in the ID column
    ! ;

M: sqlite delete-sql* ( tuple db -- string )
    #! Delete based on the ID column
    ;

M: sqlite update-sql* ( tuple db -- string )
    #! Update based on the ID column
    ;

M: sqlite select-sql* ( tuple db -- string )
    ;


