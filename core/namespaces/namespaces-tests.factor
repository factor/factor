USING: accessors assocs compiler.tree.debugger continuations kernel
locals namespaces namespaces.contexts namespaces.private sequences
tools.test vectors ;
IN: namespaces.tests

H{ } clone "test-namespace" set

: test-namespace ( -- ? )
    H{ } clone dup [ namespace = ] with-variables ;

{ t } [ test-namespace ] unit-test

10 "some-global" set
{ f }
[ H{ } clone [ f "some-global" set "some-global" get ] with-variables ]
unit-test

SYMBOL: test-initialize

f test-initialize set-global

test-initialize [ 1 ] initialize
test-initialize [ 2 ] initialize

{ 1 } [ test-initialize get-global ] unit-test

f test-initialize set-global
test-initialize [ 5 ] initialize

{ 5 } [ test-initialize get-global ] unit-test

SYMBOL: toggle-test
{ f } [ toggle-test get ] unit-test
{ t } [ toggle-test [ toggle ] [ get ] bi ] unit-test
{ f } [ toggle-test [ toggle ] [ get ] bi ] unit-test

{ t } [ toggle-test [ on ] [ get ] bi ] unit-test
{ f } [ toggle-test [ off ] [ get ] bi ] unit-test

{ t } [ [ test-initialize get-global ] { at* set-at } inlined? ] unit-test
{ t } [ [ test-initialize set-global ] { at* set-at } inlined? ] unit-test

{ t } [
    f toggle-test set
    toggle-test [ not ] change
    toggle-test get
] unit-test

SYMBOL: indexed-test-key
SYMBOL: indexed-new-key

! Internal captures preserve indexed frames and see later additions to them.
{ 3 9 f } [| |
    [
        2 indexed-test-key set capture-namestack :> saved
        3 indexed-test-key set 9 indexed-new-key set
        saved set-namestack
        indexed-test-key get indexed-new-key get
        (get-namestack) scopes>> last borrowed?>>
    ] with-scope
] unit-test

! Exported namespaces remain mutable, including insertion and deletion.
{ t 8 f } [| |
    [
        namespace :> vars get-namestack :> stack
        vars stack last eq?
        8 indexed-new-key vars set-at indexed-new-key get
        indexed-new-key vars delete-at indexed-new-key get
    ] with-scope
] unit-test

! Exception restoration removes scopes and new bindings without exporting them.
{ 2 f f } [
    [
        2 indexed-test-key set
        [ [ 3 indexed-test-key set 9 indexed-new-key set "test" throw ] with-scope ]
        [ drop ] recover
        indexed-test-key get indexed-new-key get
        (get-namestack) scopes>> last borrowed?>>
    ] with-scope
] unit-test

! A raw vector from a saved context is migrated once and keeps its assoc aliases.
{ 7 t } [| |
    [
        7 indexed-test-key set get-namestack :> stack
        stack (set-namestack)
        indexed-test-key get
        (get-namestack) namespace-context?
    ] with-scope
] unit-test

! Public snapshots can be restored repeatedly after their original scope exits.
{ 2 2 } [| |
    capture-namestack :> previous
    [
        [ 2 indexed-test-key set capture-namestack ] with-scope :> saved
        saved set-namestack indexed-test-key get
        previous set-namestack
        saved set-namestack indexed-test-key get
    ] [ previous set-namestack ] finally
] unit-test

SYMBOL: test-counter

{ 1 } [
    0 test-counter set
    test-counter inc
    test-counter get
] unit-test

{ 0 } [
    1 test-counter set
    test-counter dec
    test-counter get
] unit-test

{ 5 } [
    3 test-counter set
    2 test-counter +@
    test-counter get
] unit-test
