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

[ [ 5 4 3 1 ] ] [
    [ 5 4 3 2 1 ] "x" set
    2 "x" remove@
    "x" get
] unit-test

[ [ "hello" f ] ] [
    "x" off
    f "x" unique@
    "hello" "x" unique@
    f "x" unique@
    5 "x" unique@
    f "x" unique@
    5 "x" remove@
    "hello" "x" unique@
    "x" get
] unit-test

[ [ "xyz" #{ 3 2 } 1/5 [ { } ] ] ] [
    [, "xyz" , "xyz" unique,
    #{ 3 2 } , #{ 3 2 } unique,
    1/5 , 1/5 unique,
    [, { } unique, ,] , ,]
] unit-test

[ [ 1 2 3 4 ] ] [ [, 1 , [ 2 3 ] list, 4 , ,] ] unit-test
