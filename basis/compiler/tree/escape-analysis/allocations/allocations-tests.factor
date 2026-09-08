USING: assocs compiler.tree.escape-analysis.allocations disjoint-sets
kernel namespaces tools.test ;
IN: compiler.tree.escape-analysis.allocations.tests

! The escaping marker need not be its equivalence class's representative.
! Keep the original allocation values when selecting the escaping entries.
{ H{ { 1 { 10 11 } } { 2 t } } } [
    [
        init-escaping-values
        { 1 2 3 } introduce-values
        1 2 equate-values
        +escaping+ 1 equate-values
        H{ { 1 { 10 11 } } { 2 t } { 3 f } } allocations set
        compute-escaping-allocations
        escaping-allocations get
    ] with-scope
] unit-test

! A later analysis recomputes the marker's representative after new unions.
{ H{ } H{ { 1 t } } } [
    [
        init-escaping-values
        1 introduce-value
        H{ { 1 t } } allocations set
        compute-escaping-allocations escaping-allocations get
        1 +escaping+ equate-values
        compute-escaping-allocations escaping-allocations get
    ] with-scope
] unit-test
