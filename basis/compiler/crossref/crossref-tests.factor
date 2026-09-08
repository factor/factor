USING: accessors arrays assocs compiler.crossref fry hashtables io kernel
locals math namespaces quotations sequences sequences.private
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

! A word reached through several changed definitions only needs its
! dependency list checked once per invalidation pass, including false results.
TUPLE: test-dependency answer ;
M: test-dependency satisfied? answer>> ;

TUPLE: counted-checks contents { reads integer initial: 0 } ;
M: counted-checks length [ 1 + ] change-reads contents>> length ;
M: counted-checks nth-unsafe contents>> nth-unsafe ;

:: shared-dependency-checks ( answer strength -- outdated reads )
    answer test-dependency boa 1array
    counted-checks new swap >>contents :> checks
    gensym :> dependent
    dependent checks "dependency-checks" set-word-prop
    H{ } clone :> xref
    { 1 2 3 } [
        dependent strength 2array 1array swap xref set-at
    ] each
    xref compiled-crossref [
        { 1 2 3 } outdated-conditional-usages
        [ dependent swap key? ] map
    ] with-variable
    checks reads>> ;

{ { f f f } 1 } [ t +conditional+ shared-dependency-checks ] unit-test
{ { t t t } 1 } [ f +conditional+ shared-dependency-checks ] unit-test
{ { t t t } 1 } [ f +definition+ shared-dependency-checks ] unit-test
! Effect-only dependencies must be excluded before checking their conditions.
{ { f f f } 0 } [ f +effect+ shared-dependency-checks ] unit-test

! Equal quotations can describe different assumptions: custom inlining
! checks compare the installed hook by identity, not by contents.
:: equal-hooks ( reverse? -- outdated )
    gensym :> generic
    1 1quotation :> current
    1 1quotation :> stale
    current stale eq? f assert=
    current stale = t assert=
    generic current "custom-inlining" set-word-prop
    gensym :> valid
    gensym :> invalid
    valid generic current depends-on-custom-inlining boa 1array
    "dependency-checks" set-word-prop
    invalid generic stale depends-on-custom-inlining boa 1array
    "dependency-checks" set-word-prop
    valid +conditional+ 2array invalid +conditional+ 2array 2array
    reverse? [ reverse ] when
    1 associate compiled-crossref [
        { 1 } outdated-conditional-usages first
        [ valid swap key? ] [ invalid swap key? ] bi 2array
    ] with-variable ;

{ { f t } } [ f equal-hooks ] unit-test
{ { f t } } [ t equal-hooks ] unit-test
