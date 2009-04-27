IN: ui.gadgets.tables.tests
USING: ui.gadgets.tables ui.gadgets.scrollers ui.gadgets.debug accessors
models namespaces tools.test kernel combinators ;

SINGLETON: test-renderer

M: test-renderer row-columns drop ;

M: test-renderer column-titles drop { "First" "Last" } ;

: test-table ( -- table )
    {
        { "Britney" "Spears" }
        { "Justin" "Timberlake" }
        { "Don" "Stewart" }
    } <model> test-renderer <table> ;

[ ] [
    test-table "table" set
] unit-test

[ ] [
    "table" get <scroller> "scroller" set
] unit-test

[ { "Justin" "Timberlake" } { "Britney" "Spears" } ] [
    test-table t >>selection-required? dup [
        {
            [ 1 select-row ]
            [
                model>> {
                    { "Justin" "Timberlake" }
                    { "Britney" "Spears" }
                    { "Don" "Stewart" }
                } swap set-model
            ]
            [ selected-row drop ]
            [
                model>> {
                    { "Britney" "Spears" }
                    { "Don" "Stewart" }
                } swap set-model
            ]
            [ selected-row drop ]
        } cleave
    ] with-grafted-gadget
] unit-test