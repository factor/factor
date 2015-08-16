USING: accessors sequences tools.test ui.gadgets
ui.gadgets.labeled ;
IN: ui.gadgets.labeled.tests

{ t } [
    <gadget> "Hey" <labeled-gadget>
    children>> first content>> gadget?
] unit-test
