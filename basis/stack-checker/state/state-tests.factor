USING: accessors assocs classes.tuple compiler.tree kernel namespaces sequences
stack-checker.backend stack-checker.recursive-state stack-checker.state
stack-checker.values stack-checker.visitor tools.test ;
IN: stack-checker.state.tests

{
    V{ 1 2 3 }
} [
    0 \ <value> set-global
    init-inference
    H{ } clone known-values set
    V{ 1 2 3 } literals set commit-literals
    (meta-d) get
] unit-test

: node-seqs-eq? ( seq1 seq2 -- ? )
    [ [ tuple-slots ] map concat ] bi@ = ;

{ t t } [
    23 \ <value> set-global [
        V{ } clone stack-visitor set
        33 (push-literal)
        known-values get 24 of value>> 33 =
    ] with-infer nip
    V{
        T{ #push { literal 33 } { out-d { 24 } } }
        T{ #return { in-d V{ 24 } } }
    } node-seqs-eq?
] unit-test

{ t } [
    0 \ <value> set-global
    V{ } clone stack-visitor set
    V{ [ call ] } literals set commit-literals
    stack-visitor get
    V{ T{ #push { literal [ call ] } { out-d { 1 } } } }
    node-seqs-eq?
] unit-test
