USING: accessors db.sqlite http.server io.files.temp io.servers
io.sockets.secure.debug kernel ;
IN: webapps.utils

: <temp-sqlite3-db> ( name -- db )
    temp-file <sqlite3-db> ;

: <test-http-server> ( -- threaded-server )
    <http-server>
        <test-secure-config> >>secure-config
        8081 >>insecure
        8431 >>secure ;

: run-test-httpd ( -- )
    <test-http-server> start-server drop ;
