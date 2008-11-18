USING: io io.files io.streams.string io.encodings.utf8
html.templates html.templates.fhtml kernel
tools.test sequences parser splitting prettyprint ;
IN: html.templates.fhtml.tests

: test-template ( path -- ? )
    "resource:basis/html/templates/fhtml/test/"
    prepend
    [
        ".fhtml" append <fhtml> [ call-template ] with-string-writer
        <string-reader> lines
    ] keep
    ".html" append utf8 file-lines
    [ . . ] [ = ] 2bi ;

[ t ] [ "example" test-template ] unit-test
[ t ] [ "bug" test-template ] unit-test
[ t ] [ "stack" test-template ] unit-test

[
    [ ] [ "<%\n%>" parse-template drop ] unit-test
] with-file-vocabs
