USING: kernel math namespaces sql sql:utils ;
IN: sqlite

M: sqlite execute-sql* ( db string -- )
    >r connection-handle r>
    sqlite-prepare dup [ drop ] sqlite-each sqlite-finalize ;

M: sqlite create-table* ( db tuple -- )
    create-sql execute-sql* ;

M: sqlite drop-table* ( db tuple -- )
    drop-sql execute-sql* ;

M: sqlite insert-tuple* ( db tuple -- )
    2dup insert-sql* >r >r connection-handle r> over r>
    sqlite-prepare over bind-for-insert
    [ drop ] sqlite-each sqlite-finalize
    >r sqlite-last-insert-rowid number>string r> make-persistent ;

M: sqlite delete-tuple* ( db tuple -- )
    2dup delete-sql* >r >r connection-handle r> r>
    swapd sqlite-prepare over bind-for-delete
    [ drop ] sqlite-each sqlite-finalize remove-bottom-delegate ;

M: sqlite update-tuple* ( db tuple -- )
    2dup update-sql* >r >r connection-handle r> r>
    swapd sqlite-prepare swap bind-for-update
    [ drop ] sqlite-each sqlite-finalize drop ;

M: sqlite select-tuple* ( db tuple -- )
    2dup select-sql* >r >r connection-handle r> r>
    swapd sqlite-prepare over bind-for-select
    [ break [ break pick restore-tuple , ] sqlite-each ] { } make
    [ sqlite-finalize ] keep ;
