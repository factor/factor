IN: scratchpad
USE: math
USE: test
USE: words
USE: namespaces
USE: lists
USE: kernel

[ 4 ] [
    "poo" "scratchpad" create [ 2 2 + ] define-compound
    "poo" [ "scratchpad" ] search execute
] unit-test

: words-test ( -- ? )
    t vocabs [ words [ word? and ] each ] each ;

[ t           ] [                 ] [ words-test        ] test-word

DEFER: plist-test

[ t ] [
    \ plist-test t "sample-property" set-word-property
    \ plist-test "sample-property" word-property
] unit-test

[ f ] [
    \ plist-test f "sample-property" set-word-property
    \ plist-test "sample-property" word-property
] unit-test

: test-last ( -- ) ;
word word-name "last-word-test" set

[ "test-last" ] [ ] [ "last-word-test" get ] test-word
[ f ] [ 5 ] [ compound? ] test-word

"create-test" "scratchpad" create { 1 2 } "testing" set-word-property
[ { 1 2 } ] [
    "create-test" [ "scratchpad" ] search "testing" word-property
] unit-test

[
    <namespace> "vocabularies" set
    
    [ t ] [ \ car "car" [ "lists" ] search = ] unit-test

    "test-scope" "scratchpad" create drop
] with-scope

[ "test-scope" ] [
    "test-scope" [ "scratchpad" ] search word-name
] unit-test

[ t ] [ vocabs list? ] unit-test
[ t ] [ vocabs [ words [ word? ] all? ] all? ] unit-test

[ f ] [ gensym gensym = ] unit-test
