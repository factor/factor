! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db.tuples locals site-watcher site-watcher.db
site-watcher.private kernel db io.directories io.files.temp
continuations db.sqlite site-watcher.db.private ;
IN: site-watcher.tests

: site-watcher-path ( -- path ) "site-watcher.db" temp-file ; inline

[ site-watcher-path delete-file ] ignore-errors

: with-sqlite-db ( quot -- )
    site-watcher-path <sqlite-db> swap with-db ; inline

:: fake-sites ( -- seq )
    [
        account ensure-table
        site ensure-table
        watching-site ensure-table

        "erg@factorcode.org" insert-account
        "http://asdfasdfasdfasdfqwerqqq.com" insert-site drop
        "http://fark.com" insert-site drop

        "erg@factorcode.org" "http://asdfasdfasdfasdfqwerqqq.com" watch-site
        f <site> select-tuples
    ] with-sqlite-db ;

