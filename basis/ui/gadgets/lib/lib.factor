
USING: accessors kernel ui.backend ui.gadgets.worlds ;

IN: ui.gadgets.lib

ERROR: no-world-found ;
: find-gl-context ( gadget -- )
    find-world dup [ handle>> select-gl-context ] [ no-world-found ] if ;
