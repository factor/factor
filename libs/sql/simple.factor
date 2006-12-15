USING: generic kernel namespaces prettyprint sequences sql:utils ;
IN: sql

GENERIC: create-sql* ( tuple db -- string )
GENERIC: drop-sql* ( tuple db -- string )
GENERIC: insert-sql* ( tuple db -- string )
GENERIC: delete-sql* ( tuple db -- string )
GENERIC: update-sql* ( tuple db -- string )
GENERIC: select-sql* ( tuple db -- string )

: create-sql ( tuple -- string ) db get create-sql* ;
: drop-sql ( tuple -- string ) db get drop-sql* ;
: insert-sql ( tuple -- string ) db get insert-sql* ;
: delete-sql ( tuple -- string ) db get delete-sql* ;
: update-sql ( tuple -- string ) db get update-sql* ;
: select-sql ( tuple -- string ) db get select-sql* ;

M: connection create-sql* ( tuple db -- string )
    drop [
        "create table " %
        dup class unparse % "(" %
        tuple>mapping%
        ");" %
    ] "" make ;

M: connection drop-sql* ( tuple db -- string )
    drop [ "drop table " % tuple>sql-name % ";" % ] "" make ;

M: connection insert-sql* ( tuple db -- string )
    drop [
        "insert into " %
        dup tuple>sql-name %
        " (" % tuple>insert-parts dup first ", " join %
        ") values(" %
        second [ escape-sql enquote ] map ", " join %
        ");" %
    ] "" make ;

M: connection delete-sql* ( tuple db -- string )
    drop [
        ! "delete from table " % unparse % ";" %
    ] "" make ;

M: connection update-sql* ( tuples db -- string )
    drop [
    ] "" make ;

M: connection select-sql* ( tuples db -- string )
    drop [
    ] "" make ;


