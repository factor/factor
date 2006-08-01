IN: scratchpad
USING: alien kernel namespaces parser sequences words ;

{
    "ui"
    "clipboard"
 } [ "/library/ui/windows/" swap ".factor" append3 run-resource ] each

IN: kernel
: default-shell "tty" ;
