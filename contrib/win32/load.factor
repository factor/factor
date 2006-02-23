IN: scratchpad
USING: alien compiler kernel parser sequences words ;

{
    { "gdi" "gdi32" }
    { "user" "user32" }
    { "kernel" "kernel32" }
} [ first2 add-simple-library ] each

{ 
    "utils"
    "types"
    "gdi32"
    "kernel32"
    "user32"
    "examples"
} [ "/contrib/win32/" swap ".factor" append3 run-resource ] each
