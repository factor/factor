! (c)2009 Joe Groff bsd license
USING: accessors kernel namespaces parser sequences tools.continuations
ui.backend ui.gadgets.worlds words ;
IN: opengl.debug

SYMBOL: G-world

: G ( -- )
    G-world get set-gl-context ;

: F ( -- )
    G-world get handle>> flush-gl-context ;

: gl-break ( -- )
    world get dup G-world set-global
    [ break ] dip
    set-gl-context ;

<< \ gl-break t "break?" set-word-prop >>

SYNTAX: GB
    \ gl-break suffix! ;
