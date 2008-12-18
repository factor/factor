
USING: kernel accessors locals namespaces sequences threads
       math math.order math.vectors
       calendar
       colors opengl ui ui.gadgets ui.gestures ui.render
       circular
       processing.shapes ;

IN: trails

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Example 33-15 from the Processing book

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Return the mouse location relative to the current gadget

: mouse ( -- point ) hand-loc get  hand-gadget get screen-loc  v- ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: point-list ( n -- seq ) [ drop { 0 0 } ] map <circular> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: percent->radius ( percent -- radius ) neg 1 + 25 * 5 max ;

: dot ( pos percent -- ) percent->radius circle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <trails-gadget> < gadget paused points ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-system ( GADGET -- )

  ! Add a valid point if the mouse is in the gadget
  ! Otherwise, add an "invisible" point
  
  hand-gadget get GADGET =
    [ mouse       GADGET points>> push-circular ]
    [ { -10 -10 } GADGET points>> push-circular ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-trails-thread ( GADGET -- )
  GADGET f >>paused drop
  [
    [
      GADGET paused>>
        [ f ]
        [ GADGET iterate-system GADGET relayout-1 1 milliseconds sleep t ]
      if
    ]
    loop
  ]
  in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: <trails-gadget> pref-dim* ( <trails-gadget> -- dim ) drop { 500 500 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: each-percent ( seq quot -- )
  [
    dup length
    dup [ / ] curry
    [ 1+ ] prepose
  ] dip compose
  2each ;                       inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <trails-gadget> draw-gadget* ( GADGET -- )
  origin get
  [
    T{ rgba f 1 1 1 0.4 } \ fill-color set   ! White, with some transparency
    T{ rgba f 0 0 0 0   } \ stroke-color set ! no stroke
    
    black gl-clear

    GADGET points>> [ dot ] each-percent
  ]
  with-translation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: trails-gadget ( -- <trails-gadget> )

  <trails-gadget> new-gadget

    300 point-list >>points

    t >>clipped?

  dup start-trails-thread ;

: trails-window ( -- ) [ trails-gadget "Trails" open-window ] with-ui ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: trails-window