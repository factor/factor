IN: scratchpad
USING: alien kernel namespaces parser sequences words ;

{
    "clipboard"
    "ui"
 } [ "/library/ui/windows/" swap ".factor" append3 run-resource ] each

IN: command-line
: default-shell "tty" ;
