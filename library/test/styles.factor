IN: scratchpad
USE: lists
USE: kernel
USE: presentation
USE: test

[ t ] [ default-style assoc? ] unit-test
[ t ] [
    f "fooquux" set-style "fooquux" style default-style =
] unit-test
[ "Sans-Serif" ] [
    [
        [ "font" | "Sans-Serif" ]
    ] "fooquux" set-style
    "font" "fooquux" style assoc
] unit-test

f "fooquux" set-style
