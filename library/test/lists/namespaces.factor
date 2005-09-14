IN: temporary
USE: lists
USE: namespaces
USE: test
USE: sequences

: cons@ [ cons ] change ;

[ [ 1 ] ] [ 1 f "x" set "x" cons@ "x" get ] unit-test
[ [[ 1 2 ]] ] [ 1 2 "x" set "x" cons@ "x" get ] unit-test
[ [ 1 2 ] ] [ 1 [ 2 ] "x" set "x" cons@ "x" get ] unit-test

[ [ [[ 2 3 ]] [[ 1 2 ]] ] ] [
    "x" off 2 1 "x" [ acons ] change 3 2 "x" [ acons ] change "x" get
] unit-test

[ [ 5 4 3 1 ] ] [
    [ 5 4 3 2 1 ] "x" set
    2 "x" [ remove ] change
    "x" get
] unit-test
