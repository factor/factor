USING: html.parser html.parser.printer io.streams.string
namespaces strings tools.test ;

{
    "          "
} [
    5 #indentations [ [ indent ] with-string-writer ] with-variable
] unit-test

{
    " href='http://www.google.com' rel='nofollow'"
} [
    H{ { "href" "http://www.google.com" } { "rel" "nofollow" } }
        [ print-attributes ] with-string-writer
] unit-test

{
    "<p>\n  Sup dude!\n  <br>\n</p>\n"
} [
    "<p>Sup dude!<br></p>" parse-html [ prettyprint-html ] with-string-writer
] unit-test

! Wrongly nested tags
{
    "<div>\n  <p>\n    Sup dude!\n    <br>\n  </div>\n</p>\n"
} [
    "<div><p>Sup dude!<br></div></p>" parse-html
    [ prettyprint-html ] with-string-writer
] unit-test
