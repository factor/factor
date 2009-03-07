
USING: kernel namespaces threads sequences math math.vectors
       opengl.gl opengl colors ui ui.gadgets ui.gadgets.slate
       fry rewrite-closures vars springies accessors math.geometry.rect ;

IN: springies.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-node ( node -- ) pos>> { -5 -5 } v+ [ { 10 10 } gl-rect ] with-translation ;

: draw-spring ( spring -- )
  [ node-a>> pos>> ] [ node-b>> pos>> ] bi gl-line ;

: draw-nodes ( -- ) nodes> [ draw-node ] each ;

: draw-springs ( -- ) springs> [ draw-spring ] each ;

: set-projection ( -- )
  GL_PROJECTION glMatrixMode
  glLoadIdentity
  0 world-width 1- 0 world-height 1- -1 1 glOrtho
  GL_MODELVIEW glMatrixMode
  glLoadIdentity ;

! : display ( -- ) set-projection black gl-color draw-nodes draw-springs ;

: display ( -- ) set-projection black gl-color draw-nodes draw-springs ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

VAR: loop

: update-world-size ( -- ) slate> rect-dim >world-size ;

: refresh-slate ( -- ) slate> relayout-1 ;

DEFER: maybe-loop

: run ( -- )
  update-world-size
  iterate-system
  refresh-slate
  yield
  maybe-loop ;

: maybe-loop ( -- ) loop> [ run ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: springies-window* ( -- )

  C[ display ] <slate>
    { 800 600 } >>pdim
    C[ { 500 500 } >world-size loop on [ run ] in-thread ] >>graft
    C[ loop off ] >>ungraft
  [ >slate ] [ "Springies" open-window ] bi ;

: springies-window ( -- ) [ [ springies-window* ] with-scope ] with-ui ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: go* ( quot -- ) '[ [ springies-window* 1000 sleep @ ] with-scope ] with-ui ;
