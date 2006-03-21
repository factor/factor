IN: gadgets
USING: kernel opengl ;

DEFER: repaint-handle ( handle -- )

DEFER: in-window ( gadget status dim title -- )

DEFER: select-gl-context ( handle -- )

DEFER: flush-gl-context ( handle -- )

: with-gl-context ( handle quot -- )
    swap [ select-gl-context call ] keep
    glFlush flush-gl-context gl-error ; inline
