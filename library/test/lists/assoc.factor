IN: scratchpad
USE: lists
USE: math
USE: namespaces
USE: test

[
    [ "monkey" | 1       ]
    [ "banana" | 2       ]
    [ "Java"   | 3       ]
    [ t        | "true"  ]
    [ f        | "false" ]
    [ [ 1 2 ]  | [ 2 1 ] ]
] "assoc" set

[ t ] [ "assoc" get assoc? ] unit-test
[ f ] [ [ 1 2 3 | 4 ] assoc? ] unit-test
[ f ] [ "assoc" assoc? ] unit-test

[ f       ] [ "monkey" f           assoc ] unit-test
[ f       ] [ "donkey" "assoc" get assoc ] unit-test
[ 1       ] [ "monkey" "assoc" get assoc ] unit-test
[ "false" ] [ f        "assoc" get assoc ] unit-test
[ [ 2 1 ] ] [ [ 1 2 ]  "assoc" get assoc ] unit-test

"is great" "Java" "assoc" get set-assoc "assoc" set

[ "is great" ] [ "Java" "assoc" get assoc ] unit-test

[
    [ "one" | 1 ]
    [ "two" | 2 ]
    [ "four" | 4 ]
] "value-alist" set

[
    [ "one" + ]
    [ "three" - ]
    [ "four" * ]
] "quot-alist" set

[ 8 ] [ 1 "value-alist" get "quot-alist" get assoc-apply ] unit-test
[ 1 ] [ 1 "value-alist" get f assoc-apply ] unit-test
