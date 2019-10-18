! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.backend ui.gadgets ui.gadgets.theme ui.gadgets.lib
ui.gadgets.worlds ui.render opengl opengl.gl kernel namespaces
tuples colors ;
IN: ui.gadgets.canvas

TUPLE: canvas dlist ;

: <canvas> ( -- canvas )
    canvas construct-gadget
    dup black solid-interior ;

: delete-canvas-dlist ( canvas -- )
    dup find-gl-context
    dup canvas-dlist [ delete-dlist ] when*
    f swap set-canvas-dlist ;

: make-canvas-dlist ( canvas quot -- dlist )
    over >r GL_COMPILE swap make-dlist dup r>
    set-canvas-dlist ;

: cache-canvas-dlist ( canvas quot -- dlist )
    over canvas-dlist dup
    [ 2nip ] [ drop make-canvas-dlist ] if ; inline

: draw-canvas ( canvas quot -- )
    origin get [
        cache-canvas-dlist glCallList
    ] with-translation ; inline

M: canvas ungraft* delete-canvas-dlist ;
