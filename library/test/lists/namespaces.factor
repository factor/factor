IN: temporary
USE: lists
USE: namespaces
USE: test
USE: sequences

: cons@ [ cons ] change ;
: unique@ [ unique ] change ;

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

[ [ "hello" f ] ] [
    "x" off
    f "x" unique@
    "hello" "x" unique@
    f "x" unique@
    5 "x" unique@
    f "x" unique@
    5 "x" [ remove ] change
    "hello" "x" unique@
    "x" get
] unit-test

[ [ "xyz" #{ 3 2 }# 1/5 [ { } ] ] ] [
    [ "xyz" , "xyz" unique,
    #{ 3 2 }# , #{ 3 2 }# unique,
    1/5 , 1/5 unique,
    [ { } unique, ] [ ] make , ] [ ] make
] unit-test
