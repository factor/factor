IN: ui.gadgets.presentations.tests
USING: math ui.gadgets.presentations ui.gadgets tools.test
prettyprint ui.gadgets.buttons io io.streams.string kernel
classes.tuple ;

[ t ] [
    "Hi" \ + <presentation> [ gadget? ] is?
] unit-test

[ "+" ] [
    [
        \ + f \ pprint <command-button> dup button-quot call
    ] with-string-writer
] unit-test
