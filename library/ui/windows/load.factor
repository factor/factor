REQUIRES: library/windows ;

PROVIDE: library/ui/windows { +files+ { 
    "clipboard.factor"
    "ui.factor"
} } ;

IN: command-line
: default-shell "ui" ;
