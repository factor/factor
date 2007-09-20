USING: io io.files io.streams.string http.server.templating 
kernel tools.test sequences ;
IN: temporary

: test-template ( path -- ? )
    "extra/http/server/templating/test/" swap append
    
    [
        ".fhtml" append resource-path
        [ run-template-file ] string-out
    ] keep

    ".html" append resource-path
    <file-reader> contents
    = ;

[ t ] [ "example" test-template ] unit-test
[ t ] [ "bug" test-template ] unit-test
[ t ] [ "stack" test-template ] unit-test

[ ] [ "<%\n%>" parse-template drop ] unit-test
