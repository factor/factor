IN: gadgets
USING: generic kernel namespaces opengl ;

DEFER: set-title ( string handle -- )

DEFER: draw-world ! defined in world.factor

: redraw-world ( world -- ) draw-world ;

DEFER: open-window* ( world title -- )

DEFER: select-gl-context ( handle -- )

DEFER: flush-gl-context ( handle -- )

DEFER: user-input ( string gadget -- )

: with-gl-context ( handle quot -- )
    swap [ select-gl-context call ] keep
    glFlush flush-gl-context gl-error ; inline

! Two text transfer buffers
TUPLE: clipboard contents ;
C: clipboard "" over set-clipboard-contents ;

GENERIC: paste-clipboard ( gadget clipboard -- )

M: object paste-clipboard ( gadget clipboard -- )
    clipboard-contents dup [ swap user-input ] [ 2drop ] if ;

SYMBOL: clipboard
SYMBOL: selection

<clipboard> clipboard set-global
<clipboard> selection set-global
