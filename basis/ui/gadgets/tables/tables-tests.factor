IN: ui.gadgets.tables.tests
USING: ui.gadgets.tables ui.gadgets.scrollers accessors
models namespaces tools.test kernel ;

SINGLETON: test-renderer

M: test-renderer row-columns drop ;

M: test-renderer column-titles drop { "First" "Last" } ;

[ ] [
    {
        { "Britney" "Spears" }
        { "Justin" "Timberlake" }
        { "Don" "Stewart" }
    } <model> test-renderer <table>
    "table" set
] unit-test

[ ] [
    "table" get <scroller> "scroller" set
] unit-test