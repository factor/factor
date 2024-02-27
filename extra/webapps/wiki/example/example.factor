USING: accessors calendar db db.tuples furnace.alloy
furnace.recaptcha.example http.server io.directories
io.encodings.ascii io.files io.servers kernel namespaces sequences
splitting webapps.utils webapps.wiki websites.concatenative ;
IN: webapps.wiki.example

: wiki-db ( -- db )
    "wiki.db" <temp-sqlite3-db> ;

: insert-page ( file-name -- )
    dup ".txt" ?tail [
        swap ascii file-contents
        f <revision>
            swap >>content
            swap >>title
            "slava" >>author
            now >>date
        add-revision
    ] [ 2drop ] if ;

: insert-pages ( -- )
    "resource:extra/webapps/wiki/initial-content" [
        [ insert-page ] each
    ] with-directory-files ;

: init-wiki-db ( -- )
    wiki-db [
        init-furnace-tables
        article ensure-table
        revision ensure-table
        insert-pages
    ] with-db ;

: <wiki-app> ( -- dispatcher )
    <wiki>
    <test-recaptcha>
    <login-config>
    <factor-boilerplate>
    wiki-db <alloy> ;

: run-wiki ( -- )
    init-wiki-db
    <wiki-app> main-responder set-global
    wiki-db start-expiring
    run-test-httpd ;

MAIN: run-wiki
