USING: html.streams html.streams.private accessors io
io.streams.string io.styles kernel namespaces tools.test
sbufs sequences inspector colors xml.writer
classes.predicate prettyprint ;
IN: html.streams.tests

: make-html-string ( quot -- string )
    [ with-html-writer write-xml ] with-string-writer ; inline

[ [ ] make-html-string ] must-infer

{ "" } [
    [ "" write ] make-html-string
] unit-test

{ "a" } [
    [ CHAR: a write1 ] make-html-string
] unit-test

{ "&lt;" } [
    [ "<" write ] make-html-string
] unit-test

TUPLE: funky town ;

M: funky url-of "http://www.funky-town.com/" swap town>> append ;

{ "<a href=\"http://www.funky-town.com/austin\">&lt;</a>" } [
    [
        "<" "austin" funky boa write-object
    ] make-html-string
] unit-test

{ "<span style=\"font-family: monospace; \">car</span>" }
[
    [
        "car"
        H{ { font-name "monospace" } }
        format
    ] make-html-string
] unit-test

{ "<span style=\"color: #ff00ff; \">car</span>" }
[
    [
        "car"
        H{ { foreground T{ rgba f 1 0 1 1 } } }
        format
    ] make-html-string
] unit-test

{ "<div style=\"background-color: #ff00ff; white-space: pre; font-family: monospace; display: inline-block; \">cdr</div>" }
[
    [
        H{ { page-color T{ rgba f 1 0 1 1 } } }
        [ "cdr" write ] with-nesting
    ] make-html-string
] unit-test

{ "<div style=\"white-space: pre; font-family: monospace; display: inline-block; \"></div><br/>" } [
    [ H{ } [ ] with-nesting nl ] make-html-string
] unit-test

{ } [ [ { 1 2 3 } describe ] with-html-writer drop ] unit-test

{ "<img src=\"/icons/class-word.tiff\"/>" } [
    [
        "text"
        { { image-style "vocab:definitions/icons/class-word.tiff" } }
        format
    ] make-html-string
] unit-test
