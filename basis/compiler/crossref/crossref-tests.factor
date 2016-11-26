USING: compiler.crossref fry kernel namespaces sequences
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

! join-dependencies
{
    H{
        { 1 +effect+ }
        { 2 +effect+ }
        { 3 +conditional+ }
        { 4 +conditional+ }
        { 5 +definition+ }
        { 6 +definition+ }
    }
} [
    { 1 2 } { 3 4 } { 5 6 } join-dependencies
] unit-test
