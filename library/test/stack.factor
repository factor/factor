IN: scratchpad
USE: compiler
USE: stack
USE: stdio
USE: test

! Test the built-in stack words.

"Checking stack words." print

! OUTPUT          INPUT           WORD
[             ] [ 1           ] [ drop        ] test-word
[             ] [ 1 2         ] [ 2drop       ] test-word
[ 1 1         ] [ 1           ] [ dup         ] test-word
[ 1 2 1 2     ] [ 1 2         ] [ 2dup        ] test-word
[ 1 1 2       ] [ 1 2         ] [ dupd        ] test-word
[ 1 2 1 2 3 4 ] [ 1 2 3 4     ] [ 2dupd       ] test-word
[ 2           ] [ 1 2         ] [ nip         ] test-word
[ 3 4         ] [ 1 2 3 4     ] [ 2nip        ] test-word
[             ] [             ] [ nop         ] test-word
[ 1 2 1       ] [ 1 2         ] [ over        ] test-word
[ 1 2 3 4 1 2 ] [ 1 2 3 4     ] [ 2over       ] test-word
[ 1 2 3 1     ] [ 1 2 3       ] [ pick        ] test-word
[ 2 3 1       ] [ 1 2 3       ] [ rot         ] test-word
[ 3 4 5 6 1 2 ] [ 1 2 3 4 5 6 ] [ 2rot        ] test-word
[ 3 1 2       ] [ 1 2 3       ] [ -rot        ] test-word
[ 5 6 1 2 3 4 ] [ 1 2 3 4 5 6 ] [ 2-rot       ] test-word
[ 2 1         ] [ 1 2         ] [ swap        ] test-word
[ 3 4 1 2     ] [ 1 2 3 4     ] [ 2swap       ] test-word
[ 2 1 3       ] [ 1 2 3       ] [ swapd       ] test-word
[ 3 4 1 2 5 6 ] [ 1 2 3 4 5 6 ] [ 2swapd      ] test-word
[ 3 2 1       ] [ 1 2 3       ] [ transp      ] test-word
[ 5 6 3 4 1 2 ] [ 1 2 3 4 5 6 ] [ 2transp     ] test-word
[ 2 1 2       ] [ 1 2         ] [ tuck        ] test-word
[ 3 4 1 2 3 4 ] [ 1 2 3 4     ] [ 2tuck       ] test-word

[             ] [ 1           ] [ >r r> drop  ] test-word
[ 1 2         ] [ 1 2         ] [ >r >r r> r> ] test-word

"Stack checks passed." print
