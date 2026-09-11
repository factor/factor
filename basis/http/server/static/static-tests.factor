USING: calendar.parser http http.server.static kernel tools.test xml.writer ;

{ f } [
    <request> "not a date" "if-modified-since" set-header modified-since
] unit-test

{ f } [ <request> modified-since ] unit-test

{ t } [
    <request> "Wed, 21 Oct 2015 07:28:00 GMT" "if-modified-since" set-header
    modified-since "Wed, 21 Oct 2015 07:28:00 GMT" rfc822>timestamp =
] unit-test

{ } [ "resource:basis" directory>html write-xml ] unit-test
