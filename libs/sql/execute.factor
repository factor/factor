USING: errors generic kernel namespaces sql:utils ;
IN: sql

G: execute-sql* ( db string -- ) 1 standard-combination ; 
G: query-sql* ( db string -- seq ) 1 standard-combination ; 

: execute-sql ( string -- ) >r db get r> execute-sql* ;
: query-sql ( string -- ) >r db get r> query-sql* ;

G: create-table* ( db tuple -- ) 1 standard-combination ;
G: drop-table* ( db tuple -- ) 1 standard-combination ;
G: insert-tuple* ( db tuple -- ) 1 standard-combination ;
G: delete-tuple* ( db tuple -- ) 1 standard-combination ;
G: update-tuple* ( db tuple -- ) 1 standard-combination ;
G: select-tuple* ( db tuple -- ) 1 standard-combination ;

TUPLE: persistent-error message ;

: create-table ( tuple -- ) >r db get r> create-table* ;
: drop-table ( tuple -- ) >r db get r> drop-table* ;
: insert-tuple ( tuple -- ) 
    dup bottom-delegate persistent?
    [
        "tuple is persistent, call update not insert"
        <persistent-error> throw
    ] when
    >r db get r> insert-tuple* ;

: delete-tuple ( tuple -- )
    dup bottom-delegate persistent?
    [
        "tuple is not persistent, cannot delete"
        <persistent-error> throw
    ] unless
    >r db get r> delete-tuple* ;

: update-tuple ( tuple -- )
    dup bottom-delegate persistent?
    [
        "tuple is not persistent, call insert not update"
        <persistent-error> throw
    ] unless
    >r db get r> update-tuple* ;

: select-tuple ( tuple -- )
    >r db get r> select-tuple* ;

