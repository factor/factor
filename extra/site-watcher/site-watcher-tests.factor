! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db.tuples locals site-watcher site-watcher.db
site-watcher.private kernel db io.directories io.files.temp
continuations site-watcher.db.private db.sqlite
sequences tools.test ;
IN: site-watcher.tests

[ "site-watcher.db" temp-file delete-file ] ignore-errors

:: fake-sites ( -- seq )
    "site-watcher.db" temp-file <sqlite-db> [
        account ensure-table
        site ensure-table
        watching-site ensure-table

        "erg@factorcode.org" insert-account
        "http://asdfasdfasdfasdfqwerqqq.com" insert-site drop
        "http://fark.com" insert-site drop

        "erg@factorcode.org" "http://asdfasdfasdfasdfqwerqqq.com" watch-site
        f <site> select-tuples
    ] with-db ;

[ f ] [ fake-sites empty? ] unit-test