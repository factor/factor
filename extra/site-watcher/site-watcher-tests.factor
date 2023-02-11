! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: continuations db db.tuples io.directories io.files.temp kernel
locals sequences site-watcher.db tools.test webapps.utils ;
IN: site-watcher.tests

"site-watcher.db" temp-file ?delete-file

:: fake-sites ( -- seq )
    "site-watcher.db" <temp-sqlite-db> [
        account ensure-table
        site ensure-table
        watching-site ensure-table

        "erg" "erg@factorcode.org" insert-account
        "https://asdfasdfasdfasdfqwerqqq.com" insert-site drop
        "https://fark.com" insert-site drop

        "erg@factorcode.org" "https://asdfasdfasdfasdfqwerqqq.com" watch-site
        f <site> select-tuples
    ] with-db ;

{ f } [ fake-sites empty? ] unit-test
