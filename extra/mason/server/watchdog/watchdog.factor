! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math mason.email mason.server math.parser sequences
xml.syntax xml.writer ;
IN: mason.server.watchdog

: crashed-builder-body ( crashed-builders -- string content-type )
    [ os/cpu [XML <li><-></li> XML] ] map
    <XML
        <html>
            <body>
                <p>Machines which have not sent a heartbeat for several hours:</p>
                <ul><-></ul>
                <a href="http://builds.factorcode.org/dashboard">Dashboard</a>
            </body>
        </html>
    XML> xml>string
    "text/html" ;

: s ( n before after -- string )
    pick 1 > [ "s" append ] when
    [ number>string ] 2dip surround ;

: crashed-builder-subject ( crashed-builders -- string )
    length "Take note: " " crashed build machine" s ;

: send-crashed-builder-email ( crashed-builders -- )
    [ crashed-builder-body ]
    [ crashed-builder-subject ] bi
    mason-email ;

: check-builders ( -- )
    [
        funny-builders 2drop
        [ send-crashed-builder-email ] unless-empty
    ] with-mason-db ;
