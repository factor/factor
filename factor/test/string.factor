"Testing string words." print

[ [ 1 1 0 0 ] ] [ [ spaces ] ] [ balance>list ] test-word
[ "         " ] [ 9           ] [ spaces     ] test-word
[ ""          ] [ 0           ] [ spaces     ] test-word

: strstream-test ( -- )
    <string-output-stream> @strstream
    "Hello " $strstream fwrite
    "world." $strstream fwrite
    $strstream stream>str ;

[ "Hello world." ] [ ] [ strstream-test ] test-word

[ [ 1 1 0 0 ] ] [ [ cat ] ] [ balance>list ] test-word
[ "abc" ] [ [ "a" "b" "c" ] ] [ cat ] test-word

[ [ 1 1 0 0 ] ] [ [ chars>entities ] ] [ balance>list ] test-word
[
    "&lt;html&gt;&amp;&apos;sgml&apos;"
] [ "<html>&'sgml'" ] [ chars>entities ] test-word

"String tests done." print
