USING: xmode.code2html xmode.catalog tools.test multiline
splitting memoize kernel io.streams.string xml.writer ;

{ } [ \ (load-mode) reset-memoized ] unit-test

{ } [
    "<style type=\"text/css\" media=\"screen\" >
    *        {margin:0; padding:0; border:0;}"
    split-lines "html" htmlize-lines drop
] unit-test

{ } [
    "test.c"
    "int x = \"hi\";
/* a comment */" <string-reader> htmlize-stream
    write-xml
] unit-test

{ "<span class=\"MARKUP\">: foo</span> <span class=\"MARKUP\">;</span>" } [
    { ": foo ;" } "factor" htmlize-lines xml>string
] unit-test

{ ":foo" } [
    { ":foo" } "factor" htmlize-lines xml>string
] unit-test
