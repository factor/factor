IN: scratchpad
USE: lists
USE: kernel
USE: styles
USE: test

[ t ] [ default-style assoc? ] unit-test
[ t ] [
    f "fooquux" set-style "fooquux" get-style default-style =
] unit-test
[ "Sans-Serif" ] [
    [
        [ "font" | "Sans-Serif" ]
    ] "fooquux" set-style
    "font" "fooquux" get-style assoc
] unit-test

f "fooquux" set-style
