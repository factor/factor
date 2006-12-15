USING: kernel namespaces sql ;
IN: sqlite

M: sqlite execute-sql* ( string db -- )
    connection-handle swap
    sqlite-prepare dup [ drop ] sqlite-each sqlite-finalize ;

