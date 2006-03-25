IN: gadgets
USING: kernel opengl ;

DEFER: draw-world ! defined in world.factor

: redraw-world ( world -- ) draw-world ;

DEFER: in-window ( world title -- )

DEFER: select-gl-context ( handle -- )

DEFER: flush-gl-context ( handle -- )

: with-gl-context ( handle quot -- )
    swap [ select-gl-context call ] keep
    glFlush flush-gl-context gl-error ; inline
