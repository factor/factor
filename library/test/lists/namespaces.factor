IN: scratchpad
USE: lists
USE: namespaces
USE: test

[ [ 1 2 3 4 ] ] [ [ 3 4 ] [ 1 2 ] ] [ "x" set "x" append@ "x" get ] test-word
[ [ 1 2 3 4 ] ] [ 4 [ 1 2 3 ] ] [ "x" set "x" add@ "x" get ] test-word
[ [ 1 ] ] [ 1 f ] [ "x" set "x" cons@ "x" get ] test-word
[ [ 1 | 2 ] ] [ 1 2 ] [ "x" set "x" cons@ "x" get ] test-word
[ [ 1 2 ] ] [ 1 [ 2 ] ] [ "x" set "x" cons@ "x" get ] test-word

[ [ [ 2 | 3 ] [ 1 | 2 ] ] ] [
    "x" off 2 1 "x" acons@ 3 2 "x" acons@ "x" get
] unit-test

[ [ 2 | 3 ] ] [ "x" uncons@ ] unit-test
[ [ 1 | 2 ] ] [ "x" uncons@ ] unit-test
