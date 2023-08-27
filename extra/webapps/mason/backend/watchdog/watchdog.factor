! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: formatting kernel mason.email math sequences
webapps.mason.backend xml.syntax xml.writer ;
IN: webapps.mason.backend.watchdog

: crashed-builder-body ( crashed-builders -- string content-type )
    [ os/cpu [XML <li><-></li> XML] ] map
    <XML
        <!DOCTYPE html>
        <html>
            <body>
                <p>Machines which are not sending heartbeats:</p>
                <ul><-></ul>
                <a href="https://builds.factorcode.org/dashboard">Dashboard</a>
            </body>
        </html>
    XML> xml>string
    "text/html" ;

: crashed-builder-subject ( crashed-builders -- string )
    length dup 1 > "" "s" ?
    "Take note: %d crashed build machine%s" sprintf ;

: send-crashed-builder-email ( crashed-builders -- )
    [ crashed-builder-body ]
    [ crashed-builder-subject ] bi
    mason-email ;

: check-builders ( -- )
    [
        funny-builders drop
        [ send-crashed-builder-email ] unless-empty
    ] with-mason-db ;
