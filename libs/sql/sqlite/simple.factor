USING: generic kernel namespaces prettyprint sequences sql sql:utils ;
IN: sqlite

TUPLE: sqlite ;
C: sqlite ( path -- db )
    >r sqlite-open <connection> r>
    [ set-delegate ] keep ;

M: sqlite create-sql* ( db tuple -- string )
    nip [
        "create table " % dup tuple>sql-name %
        " (" % full-tuple>alist "id" alist-remove-key
        [ first sanitize ] map ", " join %
        ");" %
    ] "" make ;

M: sqlite drop-sql* ( db tuple -- string )
    nip [ "drop table " % tuple>sql-name % ";" % ] "" make 

M: sqlite insert-sql* ( db tuple -- string )
    #! Insert and fill in the ID column
    nip [
        "insert into " %
        dup tuple>sql-name %
        " (" % tuple>insert-alist
        [ [ first ] map ", " join % ] keep
        ") values(" %
        [ first field>sqlite-bind-name ] map ", " join %
        ");" %
    ] "" make ;

M: sqlite delete-sql* ( db tuple -- string )
    #! Delete based on the ID column
    nip [
        "delete from " % tuple>sql-name %
        " where ROWID=:rowid;" %
    ] "" make ;

M: sqlite update-sql* ( db tuple -- string )
    #! Update based on the ID column
    nip [
        "update " % dup tuple>sql-name%
        " set " % full-tuple>alist "id" alist-remove-key
        [
            [
                first [ sanitize % ] keep
                " = " % field>sqlite-bind-name %
            ] "" make
        ] map ", " join %
        " where ROWID = :rowid;" %
    ] "" make ;

M: sqlite select-sql* ( db tuple -- string )
    nip [
        "select ROWID,* from " % dup tuple>sql-name %
        " where " % tuple>select-alist
        [
            [
                first dup %
                " = " %
                field>sqlite-bind-name %
            ] "" make
        ] map " and " join %
        ";" %
    ] "" make ;


