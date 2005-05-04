! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel memory namespaces stdio ;

SYMBOL: root-menu

: show-root-menu ( -- )
    root-menu get <menu> show-menu ;

[
    [[ "Listener" [ console ] ]]
    [[ "Globals" [ global inspect ] ]]
    [[ "Save image" [ save ] ]]
    [[ "Exit" [ f world get set-world-running? ] ]]
] root-menu set

world get [ drop show-root-menu ] [ button-down 1 ] set-action
