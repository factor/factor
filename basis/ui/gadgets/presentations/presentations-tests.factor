USING: math ui.gadgets.presentations ui.gadgets tools.test
prettyprint ui.gadgets.buttons io io.streams.string kernel
classes.tuple accessors locals namespaces sequences ui.clipboards
ui.commands ui.gadgets.menus ;
IN: ui.gadgets.presentations.tests

TUPLE: selected-output < gadget selected? ;
M: selected-output gadget-selection? selected?>> ;
M: selected-output gadget-selection drop "selected definition text" ;

:: selection-menu-test ( selected? -- copied last-label )
    selected-output new selected? >>selected? :> output
    "Hi" \ + <presentation> :> presentation
    output presentation add-gadget drop
    presentation \ + [ ] presentation-menu-items last :> item
    <clipboard> :> buffer
    selected? [ buffer clipboard [ item dup quot>> call( button -- ) ] with-variable ] when
    buffer clipboard-contents
    item gadget-text ;

! Copy refers to the surrounding selection, rather than the hovered word.
{ "selected definition text" "Copy" } [ t selection-menu-test ] unit-test

{ t } [ f selection-menu-test nip "Copy" = not ] unit-test

{ t } [
    "Hi" \ + <presentation> gadget?
] unit-test

{ "+" } [
    [
        \ + f \ pprint <command-button> dup quot>> call
    ] with-string-writer
] unit-test
