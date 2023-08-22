! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server
http.server.dispatchers html.forms io.servers io.sockets
namespaces prettyprint kernel ;
IN: webapps.ip

TUPLE: ip-app < dispatcher ;

: <display-ip-action> ( -- action )
    <page-action>
        [ remote-address get host>> "ip" set-value ] >>init
        { ip-app "ip" } >>template ;

: <ip-app> ( -- dispatcher )
    ip-app new-dispatcher
        <display-ip-action> "" add-responder ;

: run-ip-app ( -- )
    <ip-app> main-responder set-global
    8080 httpd wait-for-server ;

MAIN: run-ip-app
