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
                { 20 definition-dependency }
                { 30 conditional-dependency }
                { 40 effect-dependency }
            }
        }
    } clone ;

! dependencies-of
{
    H{ { 20 definition-dependency } }
} [
    setup-crossref compiled-crossref [
        10 definition-dependency dependencies-of
    ] with-variable
] unit-test

{
    H{ { 20 definition-dependency } { 30 conditional-dependency } }
} [
    setup-crossref compiled-crossref [
        10 conditional-dependency dependencies-of
    ] with-variable
] unit-test

! join-dependencies
{
    H{
        { 1 effect-dependency }
        { 2 effect-dependency }
        { 3 conditional-dependency }
        { 4 conditional-dependency }
        { 5 definition-dependency }
        { 6 definition-dependency }
    }
} [
    { 1 2 } { 3 4 } { 5 6 } join-dependencies
] unit-test
