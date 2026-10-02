USING: accessors arrays assocs fonts hashtables kernel locals math math.order models namespaces
prettyprint.config sequences strings tools.test ui.gadgets ui.gadgets.debug ui.gadgets.tables.private
ui.text ui.tools.inspector ;

{ } [ \ + <model> <inspector-gadget> com-edit-slot ] unit-test

! Make sure we can click around in the inspector; map-index regression
{ } [ "abcdefg" make-slot-descriptions drop ] unit-test

! #2091/#2174: with limits disabled, preserve long slot strings and make
! their entire value column reachable through the horizontal scroller.
{ t t } [
    t has-limits? [ f length-limit [
        [let
            1000 CHAR: a <string> :> text
            "key" text <slot-description> :> slot
            slot value-string>> length text length 2 + =
            "key" text 2array 1array >hashtable <model> <inspector-table> :> table
            table [
                table compute-column-widths nip second
                table font>> slot value-string>> text-width >=
            ] with-grafted-gadget
        ]
    ] with-variable ] with-variable
] unit-test

! String length alone cannot identify the widest value with combining
! marks or fallback fonts, even though the inspector selects monospace.
{ t } [
    [let
        monospace-font :> font
        "a" 10 0x0301 <string> append "\u01f600\u01f600" 2array :> values
        font values inspector-column-width
        values [ font swap text-width ] map supremum >=
    ]
] unit-test
