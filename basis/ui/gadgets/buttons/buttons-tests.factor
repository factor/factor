USING: accessors kernel models namespaces tools.test ui.gadgets
ui.gadgets.buttons ;

{ } [
    2 <model> {
        { 0 "atheist" }
        { 1 "christian" }
        { 2 "muslim" }
        { 3 "jewish" }
    } <radio-buttons> "religion" set
] unit-test

{ 0 } [
    "religion" get gadget-child value>>
] unit-test

{ 2 } [
    "religion" get gadget-child control-value
] unit-test

{ t t } [
    "but1" [ ] <roll-button> "but2" [ ] <roll-button>
    [ [ boundary>> ] bi@ eq? ] [ [ interior>> ] bi@ eq? ] 2bi
] unit-test
