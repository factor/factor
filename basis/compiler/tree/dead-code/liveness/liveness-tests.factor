USING: assocs compiler.tree compiler.tree.dead-code.liveness
compiler.tree.dead-code.branches compiler.tree.dead-code.simple
compiler.tree.def-use kernel namespaces stack-checker.branches tools.test ;
IN: compiler.tree.dead-code.liveness.tests

! Follow a cycle and a shared phi input to its live leaf, ignoring bottom
! inputs and leaving an unrelated definition dead.
{ H{ { +bottom+ f } { 1 1 } { 2 2 } { 3 3 } } } [
    [
        init-dead-code
        H{ } clone def-use set
        T{ #shuffle { mapping H{ { 1 2 } } } } 1 def-value
        T{ #phi { out-d { 2 } } { phi-in-d { { 1 } { 3 } { 3 } { +bottom+ } } } }
        2 def-value
        T{ #introduce { out-d { 3 } } } 3 def-value
        T{ #introduce { out-d { 4 } } } 4 def-value
        { 1 1 +bottom+ } look-at-values
        compute-live-values
        ! Already visited values must remain safe to enqueue again.
        { 1 2 3 +bottom+ } look-at-values
        compute-live-values
        live-values get
    ] with-scope
] unit-test

{ H{ { +bottom+ f } } } [
    [
        init-dead-code
        +bottom+ look-at-value
        compute-live-values
        live-values get
    ] with-scope
] unit-test
