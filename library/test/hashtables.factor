IN: temporary
USE: hashtables
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: test
USE: vectors

16 <hashtable> "testhash" set

: silly-key/value dup dup * swap ;

1000 [ [ silly-key/value "testhash" get set-hash ] keep ] repeat

[ f ]
[ 1000 count [ silly-key/value "testhash" get hash = not ] subset ]
unit-test

[ t ]
[ "testhash" get hashtable? ]
unit-test

[ f ]
[ [[ 1 [[ 2 3 ]] ]] hashtable? ]
unit-test

! Test some hashcodes.

[ t ] [ [ 1 2 3 ] hashcode [ 1 2 3 ] hashcode = ] unit-test
[ t ] [ [[ f t ]] hashcode [[ f t ]] hashcode = ] unit-test
[ t ] [ [ 1 [ 2 3 ] 4 ] hashcode [ 1 [ 2 3 ] 4 ] hashcode = ] unit-test

[ t ] [ 12 hashcode 12 hashcode = ] unit-test
[ t ] [ 12 >bignum hashcode 12 hashcode = ] unit-test
[ t ] [ 12.0 hashcode 12 >bignum hashcode = ] unit-test

! Test various odd keys to see if they work.

16 <hashtable> "testhash" set

t #{ 2 3 }# "testhash" get set-hash
f 100000000000000000000000000 "testhash" get set-hash
{ } { [ { } ] } "testhash" get set-hash

[ t ] [ #{ 2 3 }# "testhash" get hash ] unit-test
[ f ] [ 100000000000000000000000000 "testhash" get hash* cdr ] unit-test
[ { } ] [ { [ { } ] } clone "testhash" get hash* cdr ] unit-test

[
    [[ "salmon" "fish" ]]
    [[ "crocodile" "reptile" ]]
    [[ "cow" "mammal" ]]
    [[ "visual basic" "language" ]]
] alist>hash "testhash" set

[ f ] [
    "visual basic" "testhash" get remove-hash
    "visual basic" "testhash" get hash*
] unit-test

[ 4 ] [
    "hey"
    {{ [[ "hey" 4 ]] [[ "whey" 5 ]] }} 2dup (hashcode)
    >r buckets>list r> [ cdr ] times car assoc
] unit-test

! Testing the hash element counting

<namespace> "counting" set
"value" "key" "counting" get set-hash
[ 1 ] [ "counting" get hash-size ] unit-test
"value" "key" "counting" get set-hash
[ 1 ] [ "counting" get hash-size ] unit-test
"key" "counting" get remove-hash
[ 0 ] [ "counting" get hash-size ] unit-test
"key" "counting" get remove-hash
[ 0 ] [ "counting" get hash-size ] unit-test

[ t ] [ {{ }} dup = ] unit-test
[ f ] [ "xyz" {{ }} = ] unit-test
[ t ] [ {{ }} {{ }} = ] unit-test
[ f ] [ {{ [[ 1 3 ]] }} {{ }} = ] unit-test
[ f ] [ {{ }} {{ [[ 1 3 ]] }} = ] unit-test
[ t ] [ {{ [[ 1 3 ]] }} {{ [[ 1 3 ]] }} = ] unit-test
[ f ] [ {{ [[ 1 3 ]] }} {{ [[ 1 "hey" ]] }} = ] unit-test

! Test rehashing

2 <hashtable> "rehash" set

1 1 "rehash" get set-hash
2 2 "rehash" get set-hash
3 3 "rehash" get set-hash
4 4 "rehash" get set-hash
5 5 "rehash" get set-hash
6 6 "rehash" get set-hash

[ 6 ] [ "rehash" get hash-size ] unit-test

[ 6 ] [ "rehash" get clone hash-size ] unit-test

"rehash" get hash-clear

[ 0 ] [ "rehash" get hash-size ] unit-test

[
    3
] [
    2 {{
            [[ 1 2 ]] 
            [[ 2 3 ]]
    }} clone hash
] unit-test

! There was an assoc in place of assoc* somewhere
3 <hashtable> "f-hash-test" set

10 [ f f "f-hash-test" get set-hash ] times

[ 1 ] [ "f-hash-test" get hash-size ] unit-test
