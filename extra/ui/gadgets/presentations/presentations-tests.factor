IN: temporary
USING: math ui.gadgets.presentations ui.gadgets tools.test
prettyprint ui.gadgets.buttons io io.streams.string kernel
tuples ;

[ t ] [
    "Hi" \ + <presentation> [ gadget? ] is?
] unit-test

[ "+" ] [
    [
        \ + f \ pprint <command-button> dup button-quot call
    ] string-out
] unit-test
