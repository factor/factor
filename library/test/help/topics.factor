IN: temporary
USING: help kernel sequences test words ;

! Test help cross-referencing

{ "test" "b" } "Test B" { "Hello world." } add-article

{ "test" "a" } "Test A" { { $subsection { "test" "b" } } } add-article

{ "test" "a" } remove-article

[ t ] [ { "test" "b" } parents empty? ] unit-test

SYMBOL: foo

{ "test" "a" } "Test A" { { $subsection foo } } add-article

foo { $description "Fie foe fee" } set-word-help

[ t ] [ "Fie" search-help [ first foo eq? ] contains? ] unit-test

\ foo forget

[ f ] [ "Fie" search-help [ first foo eq? ] contains? ] unit-test
