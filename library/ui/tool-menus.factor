! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: kernel memory namespaces stdio ;

SYMBOL: root-menu

: show-root-menu ( -- )
    root-menu get <menu> show-menu ;

: <console> ( -- console )
    <console-pane> <scroller> ;

[
    [[ "Listener" [ <console> "Listener" <tile> world get add-gadget ] ]]
    [[ "Globals" [ global inspect ] ]]
    [[ "Save image" [ "image" get save-image ] ]]
    [[ "Exit" [ f world get set-world-running? ] ]]
] root-menu set

world get [
    ! Note that we check if the user explicitly clicked the
    ! world, to avoid showing the root menu on gadgets that
    ! don't explicitly handle mouse clicks.
    hand hand-clicked eq? [ show-root-menu ] when
 ] [ button-down 1 ] set-action
