USING: io io.files io.streams.string
http.server.templating.fhtml kernel tools.test sequences ;
IN: http.server.templating.fhtml.tests

: test-template ( path -- ? )
    "extra/http/server/templating/fhtml/test/" swap append
    [
        ".fhtml" append resource-path
        [ run-template-file ] with-string-writer
    ] keep
    ".html" append resource-path file-contents = ;

[ t ] [ "example" test-template ] unit-test
[ t ] [ "bug" test-template ] unit-test
[ t ] [ "stack" test-template ] unit-test

[ ] [ "<%\n%>" parse-template drop ] unit-test
