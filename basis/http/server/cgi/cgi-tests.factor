! Copyright (C) 2026 Rudi Grinberg.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors assocs http http.server.cgi kernel namespaces
tools.test urls ;
IN: http.server.cgi.tests

{ "text/plain" "4" } [
    [
        <request>
            "POST" >>method
            URL" http://localhost:8080/script.cgi" >>url
            "text/plain" <post-data>
                B{ 98 111 100 121 } >>data
            >>data
        dup url>> url set request set
        "/script.cgi" cgi-variables
        [ "CONTENT_TYPE" of ] [ "CONTENT_LENGTH" of ] bi
    ] with-scope
] unit-test
