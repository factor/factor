! Copyright (C) 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel semantic-db sequences tangle.html ;
IN: tangle.menu

RELATION: subitem-of
RELATION: before

: get-menus ( -- nodes )
    subitem-of-relation ultimate-objects node-results ;

: get-menu ( name -- node )
    get-menus [ node-content = ] with find nip ;

: ensure-menu ( name -- node )
    dup get-menu [ nip ] [ create-node ] if* ;

: load-menu ( name -- menu )
    get-menu subitem-of-relation get-node-tree-s ;

: menu>ulist ( menu -- str ) children>> <ulist> ;
: menu>html ( menu -- str ) menu>ulist >html ;
