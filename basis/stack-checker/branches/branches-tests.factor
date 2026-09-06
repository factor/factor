USING: accessors continuations effects kernel namespaces quotations stack-checker stack-checker.backend
stack-checker.branches stack-checker.recursive-state
stack-checker.state stack-checker.values stack-checker.visitor
tools.test ;
FROM: sequences.private => dispatch ;
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
        { branch-effect ( x x -- ) }
    }
} [
    init-inference
    H{ } clone known-values set
    [ 2drop ] <literal> make-known push-d
    pop-d known infer-branch
] unit-test

! #2600: report the quotation effects, excluding the branch selector and
! untouched values belonging to the caller.
[ [ [ "x" ] [ ] if ] infer ]
[ actuals>> { ( -- x ) ( -- ) } = ] must-fail-with

[ [ "prefix" swap [ "x" ] [ ] if ] infer ]
[ actuals>> { ( -- x ) ( -- ) } = ] must-fail-with

[ [ [ 2drop ] [ drop ] if ] infer ]
[ actuals>> { ( x x -- ) ( x -- ) } = ] must-fail-with

[ [ { [ drop ] [ ] } dispatch ] infer ]
[ actuals>> { ( x -- ) ( -- ) } = ] must-fail-with

[ [ { [ throw ] [ ] [ 1 ] } dispatch ] infer ]
[ actuals>> { ( -- ) ( -- x ) } = ] must-fail-with
