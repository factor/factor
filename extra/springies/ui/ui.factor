
USING: kernel namespaces threads sequences math math.vectors combinators.lib
       opengl.gl opengl colors ui ui.gadgets ui.gadgets.slate
       rewrite-closures vars springies ;

IN: springies.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-node ( node -- ) node-pos { -5 -5 } v+ dup { 10 10 } v+ gl-rect ;

: draw-spring ( spring -- )
  [ spring-node-a node-pos ] [ spring-node-b node-pos ] bi gl-line ;

: draw-nodes ( -- ) nodes> [ draw-node ] each ;

: draw-springs ( -- ) springs> [ draw-spring ] each ;

: set-projection ( -- )
  GL_PROJECTION glMatrixMode
  glLoadIdentity
  0 world-width 1- 0 world-height 1- -1 1 glOrtho
  GL_MODELVIEW glMatrixMode
  glLoadIdentity ;

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

  C[ display ] <slate> >slate
    { 500 500 }					     slate> set-slate-dim
    C[ { 500 500 } >world-size loop on [ run ] in-thread ]
      slate> set-slate-graft
    C[ loop off ]	       	 	     	     slate> set-slate-ungraft

  slate> "Springies" open-window ;

: springies-window ( -- ) [ [ springies-window* ] with-scope ] with-ui ;