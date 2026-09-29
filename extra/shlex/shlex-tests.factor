USING: kernel sequences shlex tools.test ;
IN: shlex.tests

{ { } } [ "" parse-shlex ] unit-test
{ { } } [ " \t\r\n" parse-shlex ] unit-test
{ { "a" "b" "c" } } [ " a\tb\nc\r" parse-shlex ] unit-test
{ { "ab cd" "" "" } } [ "a'b c'd '' \"\"" parse-shlex ] unit-test
{ { "a b" "c\\d" "'" } } [ "a\\ b c\\\\d \\'" parse-shlex ] unit-test
{ { "a\\b" } } [ "'a\\b'" parse-shlex ] unit-test
{ { "a\"b\\c\\$d\\`e\\q" } }
[ "\"a\\\"b\\\\c\\$d\\`e\\q\"" parse-shlex ] unit-test
{ { "a\nb" } } [ "a\\\nb" parse-shlex ] unit-test
{ { "a;b|c&&d" "#comment" } } [ "a;b|c&&d #comment" parse-shlex ] unit-test
{ { "a\u00000bdata" "x\u0000a0y" } } [ "a\u00000bdata x\u0000a0y" parse-shlex ] unit-test

! POSIX comments end words; compatibility comments consume the newline.
{ { "a" "b" "#c" "#d" } }
[ "a#ignored\nb '#c' \\#d" t t shlex-split ] unit-test
{ { } } [ "# only a comment" t t shlex-split ] unit-test
{ { "a" } } [ "a#comment" t t shlex-split ] unit-test

! Compatibility mode retains quotes and treats backslashes literally.
{ { "\"Do\"" "Separate" "Do\"Not\"Separate" } }
[ "\"Do\"Separate Do\"Not\"Separate" f f shlex-split ] unit-test
{ { "''" "\"\"" "a\\" "b" } }
[ "'' \"\" a\\ b" f f shlex-split ] unit-test
{ { "ab" "'#c'" } }
[ "a#ignored\nb '#c'" t f shlex-split ] unit-test

[ "'unfinished" parse-shlex ] [ shlex-unclosed-quote? ] must-fail-with
[ "\"unfinished" parse-shlex ] [ shlex-unclosed-quote? ] must-fail-with
[ "a\\" parse-shlex ] [ shlex-missing-escape? ] must-fail-with
[ "\"a\\" parse-shlex ] [ shlex-missing-escape? ] must-fail-with
[ "'unfinished" f f shlex-split ] [ shlex-unclosed-quote? ] must-fail-with

{ "''" } [ "" shlex-quote ] unit-test
{ "abc_09@%+=:,./-" } [ "abc_09@%+=:,./-" shlex-quote ] unit-test
{ "'a'\"'\"'b'" } [ "a'b" shlex-quote ] unit-test
{ "'é'" } [ "é" shlex-quote ] unit-test
{ "echo -n 'Multiple words'" }
[ { "echo" "-n" "Multiple words" } shlex-join ] unit-test
{ "" } [ { } shlex-join ] unit-test
{ t } [
    { "" "a b" "a'b" "a\"b" "\\" "#" ";" "é" "x\ny" }
    dup shlex-join parse-shlex =
] unit-test
