! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: db.tuples locals site-watcher site-watcher.db ;
IN: site-watcher.tests

:: fake-sites ( -- seq )
    [
        account ensure-table
        site ensure-table
        watching-site ensure-table

        "erg@factorcode.org" insert-account
        "http://asdfasdfasdfasdfqwerqqq.com" insert-site
        "http://fark.com" insert-site

        "erg@factorcode.org" "http://asdfasdfasdfasdfqwerqqq.com" watch-site
        f <site> select-tuples
    ] with-sqlite-db ;

