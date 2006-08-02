IN: temporary
USING: definitions help kernel sequences test words ;

! Test help cross-referencing

{ "test" "b" } "Test B" { "Hello world." } f <article> add-article

{ "test" "a" } "Test A" { { $subsection { "test" "b" } } } f <article> add-article

{ "test" "a" } remove-article

[ t ] [ { "test" "b" } parents empty? ] unit-test

SYMBOL: foo

{ "test" "a" } "Test A" { { $subsection foo } } f <article> add-article

foo { $description "Fie foe fee" } set-word-help

[ t ] [ "Fie" search-help [ first foo eq? ] contains? ] unit-test

\ foo forget

[ f ] [ "Fie" search-help [ first foo eq? ] contains? ] unit-test
