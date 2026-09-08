USING: accessors assocs combinators disjoint-sets kernel namespaces sequences
slots.private tools.test ;
IN: disjoint-sets.tests

SYMBOL: +blah+

SYMBOL: uf

{ } [
    <disjoint-set> uf set
    +blah+ uf get add-atom
    19026 uf get add-atom
    19026 +blah+ uf get equate
] unit-test

{ 2 } [ 19026 uf get equiv-set-size ] unit-test

! Compress a path completely, including when the root is false.
{ f H{ { 1 f } { 2 f } { f f } } } [
    <disjoint-set> dup { 1 2 f } swap add-atoms
    dup parents>> [ 2 1 rot set-at ] [ f 2 rot set-at ] bi
    [ 1 swap representative ] [ parents>> ] bi
] unit-test

! Looking up an unseen atom historically introduces a parent entry. Escape
! analysis relies on that membership when finding recursive-stack inputs.
{ f t f } [
    <disjoint-set>
    [ 42 swap representative ]
    [ 42 swap disjoint-set-member? ]
    [ f swap disjoint-set-member? ] tri
] unit-test

! Repeated lookup must preserve equivalence-class sizes and unrelated sets.
{ t 3 f 1 } [
    <disjoint-set> dup { 1 2 3 4 } swap add-atoms
    dup [ 1 2 rot equate ] [ 2 3 rot equate ] bi
    dup [ 1 swap representative drop ] [ 3 swap representative drop ] bi
    {
        [ 1 3 rot equiv? ]
        [ 2 swap equiv-set-size ]
        [ 1 4 rot equiv? ]
        [ 4 swap equiv-set-size ]
    } cleave
] unit-test
