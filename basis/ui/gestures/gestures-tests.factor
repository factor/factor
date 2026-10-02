USING: accessors kernel tools.test ui.gadgets ui.gadgets.menus
ui.gadgets.tables ui.gestures ;
IN: ui.gestures.tests

TUPLE: return-control < gadget ;
return-control H{
    { T{ key-down f f "RET" } [ drop ] }
    { T{ key-down f { S+ } "RET" } [ drop "newline" drop ] }
} set-gestures

{ t } [
    T{ key-down f f "RET" } return-control new get-gesture-handler
    T{ key-down f f "ENTER" } return-control new get-gesture-handler =
] unit-test

! Preserve explicit modified bindings before falling back to unmodified Enter.
{ t } [
    T{ key-down f { S+ } "RET" } return-control new get-gesture-handler
    T{ key-down f { S+ } "ENTER" } return-control new get-gesture-handler =
] unit-test

{ t } [
    T{ key-down f f "RET" } return-control new get-gesture-handler
    T{ key-down f { C+ } "ENTER" } return-control new get-gesture-handler =
] unit-test

{ f } [
    T{ key-down f { C+ } "x" } return-control new handles-gesture?
] unit-test

{ f } [
    T{ key-up f f "ENTER" } return-control new handles-gesture?
] unit-test

! Controls with a Return action also accept keypad Enter, including modifiers.
{ t t t t } [
    T{ key-down f f "ENTER" } table new handles-gesture?
    T{ key-down f { C+ } "ENTER" } table new handles-gesture?
    T{ key-down f f "ENTER" } menu new handles-gesture?
    T{ key-down f { A+ } "RET" } menu new handles-gesture?
] unit-test

! Looking up fallbacks must not alter a queued gesture.
{ { C+ } "ENTER" } [
    T{ key-down f { C+ } "ENTER" } clone
    dup return-control new get-gesture-handler drop
    [ mods>> ] [ sym>> ] bi
] unit-test
