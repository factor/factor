USING: kernel namespaces quotations stack-checker.backend
stack-checker.branches stack-checker.recursive-state
stack-checker.state stack-checker.values stack-checker.visitor
tools.test ;
IN: stack-checker.branches.tests

! infer-branch
{
    H{
        { recursive-state T{ recursive-state } }
        { current-word f }
        { (meta-r) f }
        { input-count 2 }
        { quotation [ 2drop ] }
        { literals V{ } }
        { terminated? f }
        { stack-visitor f }
        { (meta-d) V{ } }
        { inner-d-index 0 }
    }
} [
    init-inference
    H{ } clone known-values set
    [ 2drop ] <literal> make-known push-d
    pop-d known infer-branch
] unit-test
