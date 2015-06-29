USING: accessors calendar circular colors colors.constants
kernel locals math math.order math.vectors namespaces opengl
processing.shapes sequences threads ui ui.gadgets ui.gestures
ui.render ;

IN: trails

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Example 33-15 from the Processing book

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Return the mouse location relative to the current gadget

: mouse ( -- point ) hand-loc get  hand-gadget get screen-loc  v- ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: point-list ( n -- seq ) [ { 0 0 } ] replicate <circular> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: percent->radius ( percent -- radius ) neg 1 + 25 * 5 max ;

: dot ( pos percent -- ) percent->radius circle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: trails-gadget < gadget paused points ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-system ( GADGET -- )

  ! Add a valid point if the mouse is in the gadget
  ! Otherwise, add an "invisible" point

  hand-gadget get GADGET =
    [ mouse       GADGET points>> circular-push ]
    [ { -10 -10 } GADGET points>> circular-push ]
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

M: trails-gadget pref-dim* ( trails-gadget -- dim ) drop { 500 500 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: each-percent ( seq quot -- )
  [
    dup length
    [ iota ] [ [ / ] curry ] bi
    [ 1 + ] prepose
  ] dip compose
  2each ;                       inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: trails-gadget draw-gadget* ( GADGET -- )
    T{ rgba f 1 1 1 0.4 } \ fill-color set   ! White, with some transparency
    T{ rgba f 0 0 0 0   } \ stroke-color set ! no stroke

    COLOR: black gl-clear

    GADGET points>> [ dot ] each-percent ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <trails-gadget> ( -- trails-gadget )

  trails-gadget new

    300 point-list >>points

    t >>clipped?

  dup start-trails-thread ;

: trails-window ( -- ) [ <trails-gadget> "Trails" open-window ] with-ui ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: trails-window
