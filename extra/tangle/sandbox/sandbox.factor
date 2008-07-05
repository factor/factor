USING: continuations db db.sqlite http.server io.files kernel namespaces semantic-db tangle tangle.path ;
IN: tangle.sandbox

: db-path "tangle-sandbox.db" temp-file ;
: sandbox-db db-path sqlite-db ;
: delete-db [ db-path delete-file ] ignore-errors ;

: make-sandbox ( tangle -- )
    [
        init-semantic-db
        ensure-root "foo" create-file "First Page" create-node swap has-filename
    ] with-tangle ;

: new-sandbox ( -- )
    development? on
    delete-db sandbox-db f <tangle>
    [ make-sandbox ] [ <tangle-dispatcher> ] bi
    main-responder set ;
