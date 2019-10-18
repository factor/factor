USING: math ui.gadgets.presentations ui.gadgets tools.test
prettyprint ui.gadgets.buttons io io.streams.string kernel
classes.tuple accessors ;

{ t } [
    "Hi" \ + <presentation> gadget?
] unit-test

{ "+" } [
    [
        \ + f \ pprint <command-button> dup quot>> call
    ] with-string-writer
] unit-test
