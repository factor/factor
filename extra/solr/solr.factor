! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs http http.client http.json json kernel sequences ;
IN: solr

: solr-request ( url -- json )
    dup request? [
        <get-request>
        {
            { "Content-type" "application/json" }
            { "Accept" "text/plain" }
        } set-headers
    ] unless
    http-request-json nip ;

: solr-docs ( url -- json )
    solr-request "response" of "docs" of ;

: get-solr-cores ( url -- json )
    "/solr/admin/cores" append solr-request ;

: get-solr-core-names ( url -- json )
    get-solr-cores "status" of keys ;
