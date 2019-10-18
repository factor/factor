USING: http.server.static tools.test xml.writer ;

{ } [ "resource:basis" directory>html write-xml ] unit-test
