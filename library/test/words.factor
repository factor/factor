IN: temporary
USING: arrays generic hashtables kernel math namespaces
sequences test words ;

[ 4 ] [
    "poo" "scratchpad" create [ 2 2 + ] define-compound
    "poo" "scratchpad" lookup execute
] unit-test

[ t ] [ t vocabs [ words [ word? and ] each ] each ] unit-test

DEFER: plist-test

[ t ] [
    \ plist-test t "sample-property" set-word-prop
    \ plist-test "sample-property" word-prop
] unit-test

[ f ] [
    \ plist-test f "sample-property" set-word-prop
    \ plist-test "sample-property" word-prop
] unit-test

[ f ] [ 5 compound? ] unit-test

"create-test" "scratchpad" create { 1 2 } "testing" set-word-prop
[ { 1 2 } ] [
    "create-test" "scratchpad" lookup "testing" word-prop
] unit-test

[
    [ t ] [ \ array? "array?" "arrays" lookup = ] unit-test

    "test-scope" "scratchpad" create drop
] with-scope

[ "test-scope" ] [
    "test-scope" "scratchpad" lookup word-name
] unit-test

[ t ] [ vocabs array? ] unit-test
[ t ] [ vocabs [ words [ word? ] all? ] all? ] unit-test

[ f ] [ gensym gensym = ] unit-test

[ f ] [ 123 compound? ] unit-test

: colon-def ;
[ t ] [ \ colon-def compound? ] unit-test

SYMBOL: a-symbol
[ f ] [ \ a-symbol compound? ] unit-test
[ t ] [ \ a-symbol symbol? ] unit-test

! See if redefining a generic as a colon def clears some
! word props.
GENERIC: testing
: testing ;

[ f ] [ \ testing generic? ] unit-test

[ f ] [ gensym interned? ] unit-test

: forgotten ;
: another-forgotten ;

[ f ] [ \ forgotten interned? ] unit-test

FORGET: forgotten

[ f ] [ \ another-forgotten interned? ] unit-test

FORGET: another-forgotten
: another-forgotten ;

[ t ] [ \ + interned? ] unit-test

! I forgot remove-crossref calls!
: fee ;
: foe fee ;
: fie foe ;

[ 0 ] [ \ fee crossref get hash hash-size ] unit-test
[ t ] [ \ foe crossref get hash not ] unit-test

FORGET: foe

! This has to be the last test in the file.
: test-last ( -- ) ;
word word-name "last-word-test" set

[ "test-last" ] [ "last-word-test" get ] unit-test

! xref should not retain references to gensyms
gensym [ * ] define-compound
[ t ] [ \ * usage [ interned? not ] subset empty? ] unit-test
