! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: resource-responder
USING: httpd kernel lists namespaces stdio streams ;

: resource-response ( mime-type -- )
    "Content-Type" swons unit "200 OK" response terpri ;

: serve-resource ( filename mime-type -- )
    dup mime-type resource-response  "method" get "head" = [
        drop
    ] [
        <resource-stream> stdio get stream-copy
    ] ifte ;

: resource-responder ( filename -- )
    "resource-path" get [
        serve-resource
    ] [
        drop "404 resource-path not set" httpd-error
    ] ifte ;
