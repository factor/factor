REQUIRES: core/windows ;

PROVIDE: core/ui/windows { +files+ { 
    "clipboard.factor"
    "ui.factor"
} } ;

IN: command-line
: default-shell "ui" ;
