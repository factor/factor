
USING: kernel
       namespaces
       arrays
       accessors
       strings
       sequences
       locals
       threads
       math
       math.functions
       math.trig
       math.order
       math.ranges
       math.vectors
       random
       calendar
       opengl.gl
       opengl
       ui
       ui.gadgets
       ui.gadgets.tracks
       ui.gadgets.frames
       ui.gadgets.grids
       ui.render
       multi-methods
       multi-method-syntax
       combinators.short-circuit
       processing.shapes
       flatland ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: boids

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: constrain ( n a b -- n ) rot min max ;

: angle-between ( vec vec -- angle )
  [ v. ] [ [ norm ] bi@ * ] 2bi / -1 1 constrain acos rad>deg ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: relative-position ( self other -- v ) swap [ pos>> ] bi@ v- ;

: relative-angle ( self other -- angle )
  over vel>> -rot relative-position angle-between ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: in-radius? ( self other radius -- ? ) [ distance       ] dip     <= ;
: in-view?   ( self other angle  -- ? ) [ relative-angle ] dip 2 / <= ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: vsum ( vector-of-vectors -- vec ) { 0 0 } [ v+ ] reduce ;

: vaverage ( seq-of-vectors -- seq ) [ vsum ] [ length ] bi v/n ;

: average-position ( boids -- pos ) [ pos>> ] map vaverage ;
: average-velocity ( boids -- vel ) [ vel>> ] map vaverage ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <boid> < <vel> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <behaviour>
  { weight     initial: 1.0 }
  { view-angle initial: 180 }
  { radius                  } ;

TUPLE: <cohesion>   < <behaviour> { radius initial: 75 } ;
TUPLE: <alignment>  < <behaviour> { radius initial: 50 } ;
TUPLE: <separation> < <behaviour> { radius initial: 25 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: within-neighborhood? ( SELF OTHER BEHAVIOUR -- ? )

  SELF OTHER
    {
      [ BEHAVIOUR radius>>     in-radius? ]
      [ BEHAVIOUR view-angle>> in-view?   ]
      [ eq? not                           ]
    }
  2&& ;

:: neighborhood ( SELF OTHERS BEHAVIOUR -- boids )
  OTHERS [| OTHER | SELF OTHER BEHAVIOUR within-neighborhood? ] filter ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: normalize* ( u -- v ) { 0.001 0.001 } v+ normalize ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: force* ( sequence <boid> <behaviour> -- force )

:: cohesion-force ( OTHERS SELF BEHAVIOUR -- force )
  OTHERS average-position SELF pos>> v- normalize* BEHAVIOUR weight>> v*n ;

:: alignment-force ( OTHERS SELF BEHAVIOUR -- force )
  OTHERS average-velocity normalize* BEHAVIOUR weight>> v*n ;

:: separation-force ( OTHERS SELF BEHAVIOUR -- force )
  SELF pos>> OTHERS average-position v- normalize* BEHAVIOUR weight>> v*n ;

METHOD: force* ( sequence <boid> <cohesion>   -- force ) cohesion-force   ;
METHOD: force* ( sequence <boid> <alignment>  -- force ) alignment-force  ;
METHOD: force* ( sequence <boid> <separation> -- force ) separation-force ;

:: force ( OTHERS SELF BEHAVIOUR -- force )
  SELF OTHERS BEHAVIOUR neighborhood
    [ { 0 0 } ]
    [ SELF BEHAVIOUR force* ]
  if-empty ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: random-boids ( count -- boids )
  [
    drop
    <boid> new
      2 [ drop         1000 random ] map >>pos
      2 [ drop -10 10 [a,b] random ] map >>vel
  ]
  map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: draw-boid ( boid -- )
  glPushMatrix
    dup pos>> gl-translate-2d
        vel>> first2 rect> arg rad>deg 0 0 1 glRotated
    { { 0 5 } { 0 -5 } { 20 0 } } triangle
    fill-mode
  glPopMatrix ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gadget->sky ( gadget -- sky ) { 0 0 } swap dim>> <rectangle> boa ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: syntax ! Switch back to non-multi-method 'TUPLE:' syntax

TUPLE: <boids-gadget> < gadget paused boids behaviours time-slice ;

M:  <boids-gadget> pref-dim*    ( <boids-gadget> -- dim ) drop { 600 400 } ;
M:  <boids-gadget> ungraft*     ( <boids-gadget> --     ) t >>paused drop  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-system ( BOIDS-GADGET -- )

  [let | SKY        [ BOIDS-GADGET gadget->sky   ]
         BOIDS      [ BOIDS-GADGET boids>>       ]
         TIME-SLICE [ BOIDS-GADGET time-slice>>  ]
         BEHAVIOURS [ BOIDS-GADGET behaviours>>  ] |

    BOIDS

      [| SELF |

        [wlet | force-due-to [| BEHAVIOUR | BOIDS SELF BEHAVIOUR force ] |

          ! F = m a. M is 1. So F = a.
            
          [let | ACCEL [ BEHAVIOURS [ force-due-to ] map vsum ] |

            [let | POS [ SELF pos>> SELF vel>> TIME-SLICE v*n v+ ]
                   VEL [ SELF vel>> ACCEL      TIME-SLICE v*n v+ ] |

              [let | POS [ POS SKY wrap   ]
                     VEL [ VEL normalize* ] |
                    
                T{ <boid> f POS VEL } ] ] ] ]

      ]
      
    map

    BOIDS-GADGET (>>boids) ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <boids-gadget> draw-gadget* ( BOIDS-GADGET -- )
  origin get
    [ BOIDS-GADGET boids>> [ draw-boid ] each ]
  with-translation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-boids-thread ( GADGET -- )
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

: default-behaviours ( -- seq )
  { <cohesion> <alignment> <separation> } [ new ] map ;

: boids-gadget ( -- gadget )
  <boids-gadget> new-gadget
    100 random-boids   >>boids
    default-behaviours >>behaviours
    10                 >>time-slice
    t                  >>clipped? ;

: run-boids ( -- ) boids-gadget dup "Boids" open-window start-boids-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USING: math.parser
       ui.gadgets.labels
       ui.gadgets.buttons
       ui.gadgets.packs ;

: truncate-number ( n -- n ) 10 * round 10 / ;

:: make-behaviour-control ( NAME BEHAVIOUR -- gadget )
  [let | NAME-LABEL  [ NAME           <label> reverse-video-theme ]
         VALUE-LABEL [ 20 32 <string> <label> reverse-video-theme ] |

    [wlet | update-value-label [ ! ( -- )
              BEHAVIOUR weight>> truncate-number number>string
              VALUE-LABEL
              (>>string) ] |

      update-value-label
      
    <pile> 1 >>fill
      { 1 0 } <track>
        NAME-LABEL  0.5 track-add
        VALUE-LABEL 0.5 track-add
      add-gadget
      
      "+0.1"
      [
        drop
        BEHAVIOUR [ 0.1 + ] change-weight drop
        update-value-label
      ]
      <bevel-button> add-gadget
      
      "-0.1"
      [
        drop
        BEHAVIOUR weight>> 0.1 >
        [
          BEHAVIOUR [ 0.1 - ] change-weight drop
          update-value-label
        ]
        when
      ]
      <bevel-button> add-gadget ] ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: make-population-control ( BOIDS-GADGET -- gadget )
  [let | VALUE-LABEL [ 20 32 <string> <label> reverse-video-theme ] |

    [wlet | update-value-label [ ( -- )
              BOIDS-GADGET boids>> length number>string
              VALUE-LABEL
              (>>string) ] |

      update-value-label
      
      <pile> 1 >>fill
    
        { 1 0 } <track>
          "Population: " <label> reverse-video-theme 0.5 track-add
          VALUE-LABEL                                0.5 track-add
        add-gadget

        "Add 10"
        [
          drop
          BOIDS-GADGET
            BOIDS-GADGET boids>> 10 random-boids append
          >>boids
          drop
          update-value-label
        ]
        <bevel-button>
        add-gadget

        "Sub 10"
        [
          drop
          BOIDS-GADGET boids>> length 10 >
          [
            BOIDS-GADGET
              BOIDS-GADGET boids>> 10 tail
            >>boids
            drop
            update-value-label
          ]
          when
        ]
        <bevel-button>
        add-gadget ] ] ( gadget -- gadget ) ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: pause-toggle ( BOIDS-GADGET -- )
  BOIDS-GADGET paused>>
    [ BOIDS-GADGET start-boids-thread ]
    [ BOIDS-GADGET t >>paused drop    ]
  if ;

:: randomize-boids ( BOIDS-GADGET -- )
  BOIDS-GADGET   BOIDS-GADGET boids>> length random-boids   >>boids drop ;

: boids-app ( -- )

  [let | BOIDS-GADGET [ boids-gadget ] |

    <frame>

      <shelf>

        1 >>fill

        "Pause" [ drop BOIDS-GADGET pause-toggle ] <bevel-button> add-gadget

        "Randomize"
        [ drop BOIDS-GADGET randomize-boids ] <bevel-button> add-gadget

        BOIDS-GADGET make-population-control add-gadget
    
        "Cohesion:   " BOIDS-GADGET behaviours>> first  make-behaviour-control 
        "Alignment:  " BOIDS-GADGET behaviours>> second make-behaviour-control
        "Separation: " BOIDS-GADGET behaviours>> third  make-behaviour-control

        [ add-gadget ] tri@

      @top grid-add

      BOIDS-GADGET @center grid-add

    "Boids" open-window

    BOIDS-GADGET start-boids-thread ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boids-main ( -- ) [ boids-app ] with-ui ;

MAIN: boids-main