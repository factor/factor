IN: temporary
USING: math gadgets-presentations gadgets generic test
prettyprint gadgets-buttons io kernel ;

[ t ] [
    "Hi" \ + <presentation> [ gadget? ] is?
] unit-test

[ "+" ] [
    [
        \ +
        "Test" f [ pprint ] <command> <command-button>
        dup button-quot call
    ] string-out
] unit-test
