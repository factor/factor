! To do: merge this with libs/slate?
USING: gadgets gadgets-theme opengl kernel namespaces
generic ;
IN: canvas

TUPLE: canvas dlist ;

C: canvas ( -- canvas )
    dup delegate>gadget
    dup black solid-interior ;

: delegate>canvas ( gadget -- )
    <canvas> swap set-delegate ;

: find-gl-context ( gadget -- )
    find-world world-handle select-gl-context ;

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

PROVIDE: libs/canvas ;
