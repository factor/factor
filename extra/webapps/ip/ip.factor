! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors furnace.actions http.server.dispatchers
html.forms io.servers.connection namespaces prettyprint ;
IN: webapps.ip

TUPLE: ip-app < dispatcher ;

: <display-ip-action> ( -- action )
    <page-action>
        [ remote-address get host>> "ip" set-value ] >>init
        { ip-app "ip" } >>template ;

: <ip-app> ( -- dispatcher )
    ip-app new-dispatcher
        <display-ip-action> "" add-responder ;
