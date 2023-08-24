USING: accessors sequences tools.test ui.gadgets
ui.gadgets.labeled ;

{ t } [
    <gadget> "Hey" <labeled-gadget> content>> gadget?
] unit-test
