
USING: kernel namespaces math quotations arrays hashtables sequences threads
       opengl
       opengl.gl
       colors
       ui
       ui.gestures
       ui.gadgets
       ui.gadgets.handler
       ui.gadgets.slate
       ui.gadgets.labels
       ui.gadgets.buttons
       ui.gadgets.frames
       ui.gadgets.packs
       ui.gadgets.grids
       ui.gadgets.theme
       namespaces.lib hashtables.lib vars
       rewrite-closures automata ;

IN: automata.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-point ( y x value -- ) 1 = [ swap glVertex2i ] [ 2drop ] if ;

: draw-line ( y line -- ) 0 swap [ >r 2dup r> draw-point 1+ ] each 2drop ;

: (draw-bitmap) ( bitmap -- ) 0 swap [ >r dup r> draw-line 1+ ] each drop ;

: draw-bitmap ( bitmap -- ) GL_POINTS glBegin (draw-bitmap) glEnd ;

: display ( -- ) black gl-color bitmap> draw-bitmap ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: slate

! Call a 'model' quotation with the current 'view'.

: with-view ( quot -- )
slate> rect-dim first >width
slate> rect-dim second >height
call
slate> relayout-1 ;

! Create a quotation that is appropriate for buttons and gesture handler.

: view-action ( quot -- quot ) [ drop [ ] with-view ] make* closed-quot ;

: view-button ( label quot -- ) >r <label> r> view-action <bevel-button> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Helper word to make things less verbose

: random-rule ( -- ) set-interesting start-center ;

DEFER: automata-window

: automata-window* ( -- ) init-rule set-interesting <frame>

{
[ "1 - Center"      [ start-center    ] view-button ]
[ "2 - Random"      [ start-random    ] view-button ]
[ "3 - Continue"    [ run-rule 	      ] view-button ]
[ "5 - Random Rule" [ random-rule     ] view-button ]
[ "n - New"   	    [ automata-window ] view-button ]
} make*
[ [ gadget, ] curry ] map concat ! Hack
make-shelf over @top grid-add

[ display ] closed-quot <slate> { 400 400 } over set-slate-dim dup >slate
over @center grid-add

{
{ T{ key-down f f "1" } [ [ start-center    ] view-action ] }
{ T{ key-down f f "2" } [ [ start-random    ] view-action ] }
{ T{ key-down f f "3" } [ [ run-rule 	    ] view-action ] }
{ T{ key-down f f "5" } [ [ random-rule     ] view-action ] }
{ T{ key-down f f "n" } [ [ automata-window ] view-action ] }
} [ make* ] map >hashtable <handler> tuck set-gadget-delegate
"Automata" open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: automata-window ( -- ) [ [ automata-window* ] with-scope ] with-ui ;

MAIN: automata-window