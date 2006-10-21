PROVIDE: library/windows
{ +files+ { 
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
    "winsock.factor"
    "opengl32.factor"
    "utils.factor"
} } ;

IN: command-line
: default-shell "tty" ;
