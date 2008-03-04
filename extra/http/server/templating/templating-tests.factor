USING: io io.files io.streams.string http.server.templating kernel tools.test
    sequences io.encodings.utf8 ;
IN: http.server.templating.tests

: test-template ( path -- ? )
    "extra/http/server/templating/test/" swap append
    [
        ".fhtml" append resource-path
        [ run-template-file ] with-string-writer
    ] keep
    ".html" append resource-path utf8 file-contents = ;

[ t ] [ "example" test-template ] unit-test
[ t ] [ "bug" test-template ] unit-test
[ t ] [ "stack" test-template ] unit-test

[ ] [ "<%\n%>" parse-template drop ] unit-test
