PROVIDE: library/windows {
    "windows-messages.factor"
    "types.factor"
    "gdi32-constants.factor"
    "gdi32.factor"
    "kernel32-constants.factor"
    "kernel32-structs.factor"
    "kernel32-types.factor"
    "kernel32.factor"
    "user32-constants.factor"
    "user32-structs.factor"
    "user32-types.factor"
    "user32.factor"
    "opengl32.factor"
    "utils.factor"
} ;

{ 
    "windows-messages"
    "types"
    "gdi32-constants"
    "gdi32"
    "kernel32-constants"
    "kernel32-structs"
    "kernel32-types"
    "kernel32"
    "user32-constants"
    "user32-structs"
    "user32-types"
    "user32"
    "opengl32"
    "utils"
} [ "/library/windows/" swap ".factor" append3 run-resource ] each
    
IN: command-line
: default-shell "tty" ;
