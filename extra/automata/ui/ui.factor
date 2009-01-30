
USING: kernel namespaces math quotations arrays hashtables sequences threads
       opengl
       opengl.gl
       colors
       ui
       ui.gestures
       ui.gadgets
       ui.gadgets.slate
       ui.gadgets.labels
       ui.gadgets.buttons
       ui.gadgets.frames
       ui.gadgets.packs
       ui.gadgets.grids
       ui.gadgets.theme
       ui.gadgets.handler
       accessors
       vars fry
       rewrite-closures automata math.geometry.rect newfx ;

IN: automata.ui

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-point ( y x value -- ) 1 = [ swap glVertex2i ] [ 2drop ] if ;

: draw-line ( y line -- ) 0 swap [ [ 2dup ] dip draw-point 1+ ] each 2drop ;

: (draw-bitmap) ( bitmap -- ) 0 swap [ [ dup ] dip draw-line 1+ ] each drop ;

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

: view-action ( quot -- quot ) '[ drop _ with-view ] closed-quot ;

: view-button ( label quot -- button ) [ <label> ] dip view-action <bevel-button> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Helper word to make things less verbose

: random-rule ( -- ) set-interesting start-center ;

DEFER: automata-window

: automata-window* ( -- )
  init-rule
  set-interesting

  <frame>

    <shelf>

      "1 - Center"      [ start-center    ] view-button add-gadget
      "2 - Random"      [ start-random    ] view-button add-gadget
      "3 - Continue"    [ run-rule        ] view-button add-gadget
      "5 - Random Rule" [ random-rule     ] view-button add-gadget
      "n - New"         [ automata-window ] view-button add-gadget

    @top grid-add

    C[ display ] <slate>
      { 400 400 } >>pdim
    dup >slate

    @center grid-add

  <handler>

  H{ }
    T{ key-down f f "1" } [ start-center    ] view-action is
    T{ key-down f f "2" } [ start-random    ] view-action is
    T{ key-down f f "3" } [ run-rule        ] view-action is
    T{ key-down f f "5" } [ random-rule     ] view-action is
    T{ key-down f f "n" } [ automata-window ] view-action is

  >>table

  "Automata" open-window ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: automata-window ( -- ) [ [ automata-window* ] with-scope ] with-ui ;

MAIN: automata-window
