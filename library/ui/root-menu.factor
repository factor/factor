! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel memory namespaces ;

SYMBOL: root-menu

: show-root-menu ( -- )
    root-menu get <menu> show-menu ;

[
    [[ "Listener" [ <console-pane> <scroller> world get add-gadget ] ]]
    [[ "Globals" [ global inspect ] ]]
    [[ "Save image" [ "image" get save-image ] ]]
    [[ "Exit" [ f world get set-world-running? ] ]]
] root-menu set

world get [ drop show-root-menu ] [ button-down 1 ] set-action
