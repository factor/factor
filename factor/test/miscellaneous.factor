! Miscellaneous tests.

"Miscellaneous tests." print

: test-last ( -- )
    nop ;
word >str @last-word-test

[ "test-last" ] [ ] [ $last-word-test ] test-word
[ f ] [ 5 ] [ compound? ] test-word
[ f ] [ 5 ] [ compiled? ] test-word
[ f ] [ 5 ] [ shuffle?  ] test-word

! These stress-test a lot of code.
"prettyprint*" see
"prettyprint*" see/html
$global describe
$global describe/html

[ t ] [ ] [ [ "global" "stdio" ] object-path $stdio = ] test-word

"Miscellaneous passed." print
