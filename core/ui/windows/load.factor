REQUIRES: core/windows core/ui/tools ;

PROVIDE: core/ui/windows { +files+ { 
    "clipboard.factor"
    "ui.factor"
} } ;

IN: command-line
: default-shell "ui" ;
