USING: io io.files io.streams.string io.encodings.utf8
http.server.templating.fhtml kernel tools.test sequences
parser ;
IN: http.server.templating.fhtml.tests

: test-template ( path -- ? )
    "resource:extra/http/server/templating/fhtml/test/"
    prepend
    [
        ".fhtml" append [ run-template ] with-string-writer
    ] keep
    ".html" append utf8 file-contents = ;

[ t ] [ "example" test-template ] unit-test
[ t ] [ "bug" test-template ] unit-test
[ t ] [ "stack" test-template ] unit-test

[
    [ ] [ "<%\n%>" parse-template drop ] unit-test
] with-file-vocabs
