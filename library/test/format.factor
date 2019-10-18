IN: scratchpad
USE: compiler
USE: format
USE: namespaces
USE: stdio
USE: test

"Testing formatting words." print

[ [ 2 1 0 0 ] ] [ [ decimal-places ] ] [ balance>list ] test-word
[ "123" ] [ "123" ] [ 2 decimal-places ] test-word
[ "123.12" ] [ "123.12" ] [ 2 decimal-places ] test-word
[ "123.123" ] [ "123.123" ] [ 5 decimal-places ] test-word
[ "123" ] [ "123.123" ] [ 0 decimal-places ] test-word

"Formatting tests done." print
