IN: scratchpad
USING: alien compiler kernel parser sequences words ;

{
    { "gdi" "gdi32" }
    { "user" "user32" }
    { "kernel" "kernel32" }
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
