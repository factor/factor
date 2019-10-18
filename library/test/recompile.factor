IN: scratchpad
USE: arithmetic
USE: compiler
USE: kernel
USE: stdio
USE: test
USE: words
USE: vocabularies

"Recompile test." print

: recompile-test 2 2 + ; word must-compile
: recompile-dependency recompile-test 3 * ; word must-compile

[ 4 ] [ ] [ recompile-test ] test-word
[ 12 ] [ ] [ recompile-dependency ] test-word

: recompile-test 2 3 + ; word must-compile

"recompile-dependency" [ "scratchpad" ] search recompile

[ 15 ] [ ] [ recompile-dependency ] test-word

"Recompile test done." print
