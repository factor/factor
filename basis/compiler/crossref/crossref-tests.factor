USING: assocs compiler.crossref fry io kernel namespaces sequences
stack-checker.dependencies tools.test vocabs words ;
IN: compiler.crossref.tests

! Dependencies of all words should always be satisfied unless we're
! in the middle of recompiling something
{ { } } [
    all-words dup [ subwords ] map concat append
    H{ } clone '[ _ dependencies-satisfied? ] reject
] unit-test

: setup-crossref ( -- assoc )
    H{
        {
            10
            H{
                { 20 +definition+ }
                { 30 +conditional+ }
                { 40 +effect+ }
            }
        }
    } clone ;

! compiled-unxref
SYMBOL: kolobi
{ f f } [
    ! Setup a fake dependency; kolobi -> print
    +effect+ kolobi compiled-crossref get \ print of set-at
    kolobi { print } "dependencies" set-word-prop

    ! Ensure it is being forgotten
    kolobi compiled-unxref
    kolobi "dependencies" word-prop
    compiled-crossref get \ print of kolobi of
] unit-test

! dependencies-of
{
    H{ { 20 +definition+ } }
} [
    setup-crossref compiled-crossref [
        10 +definition+ dependencies-of
    ] with-variable
] unit-test

{
    H{ { 20 +definition+ } { 30 +conditional+ } }
} [
    setup-crossref compiled-crossref [
        10 +conditional+ dependencies-of
    ] with-variable
] unit-test

! remove-xref
SYMBOLS: foo1 bar ;
{
    H{ { foo1 H{ } } }
} [
    bar { foo1 }
    H{
        { foo1 H{ { bar +definition+ } } }
    } clone [ remove-xref ] keep
] unit-test

! store-dependencies
: setup-deps ( -- assoc )
    H{
        { 20 +definition+ }
        { 30 +conditional+ }
        { 40 +effect+ }
        { 50 +effect+ }
    } ;

SYMBOL: foo
{
    { 40 50 20 30 }
} [
    foo [ setup-deps store-dependencies ] keep "dependencies" word-prop
    foo delete-compiled-xref
] unit-test
