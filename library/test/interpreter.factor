IN: scratchpad
USE: interpreter
USE: namespaces
USE: stdio
USE: test

[
    [ 4 ] [ "2 2 +" eval-catch ] unit-test
    "The following will print an error; ignore it." print terpri
    [ ] [ "clear drop" eval-catch ] unit-test
] with-scope
