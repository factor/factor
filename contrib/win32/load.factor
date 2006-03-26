IN: scratchpad
USING: alien compiler kernel parser sequences words ;

{
    { "gdi32" "gdi32" }
    { "user32" "user32" }
    { "kernel32" "kernel32" }
} [ first2 add-simple-library ] each

{ 
    "windows-messages"
    "types"
    "gdi32"
    "kernel32"
    "user32"
    "opengl32"
    "utils"
    "clipboard"
    "ui"
} [ "/contrib/win32/" swap ".factor" append3 run-resource ] each
compile-all
