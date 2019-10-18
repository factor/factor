PROVIDE: core/ui/windows
{ +files+ { 
    "clipboard.factor"
    "ui.factor"
} } ;

IN: command-line
: default-shell ( -- string ) "ui" ;
