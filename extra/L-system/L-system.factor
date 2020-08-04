
USING: accessors arrays assocs calendar colors
combinators.short-circuit help.markup help.syntax kernel locals
math math.functions math.matrices math.order math.parser
math.trig math.vectors opengl opengl.demo-support opengl.gl
sbufs sequences strings threads ui.gadgets ui.gadgets.worlds
ui.gestures ui.render ui.tools.workspace ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

IN: L-system

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <turtle> pos ori angle length thickness color vertices saved ;

DEFER: default-L-parser-values

: reset-turtle ( turtle -- turtle )
  { 0 0 0 } clone   >>pos
  3 identity-matrix >>ori
  V{ } clone >>vertices
  V{ } clone >>saved

  default-L-parser-values ;

: turtle ( -- turtle ) <turtle> new reset-turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: step-turtle ( TURTLE LENGTH -- turtle )

  TURTLE
    TURTLE pos>>   TURTLE ori>> { 0 0 LENGTH } m.v   v+
  >>pos ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: Rx ( ANGLE -- Rx )
  
  [let | ANGLE [ ANGLE deg>rad ] |

    [let | A [ ANGLE cos     ]
           B [ ANGLE sin neg ]
           C [ ANGLE sin     ]
           D [ ANGLE cos     ] |

      { { 1 0 0 }
        { 0 A B }
        { 0 C D } }

    ] ] ;

:: Ry ( ANGLE -- Ry )
  
  [let | ANGLE [ ANGLE deg>rad ] |

    [let | A [ ANGLE cos     ]
           B [ ANGLE sin     ]
           C [ ANGLE sin neg ]
           D [ ANGLE cos     ] |

      { { A 0 B }
        { 0 1 0 }
        { C 0 D } }

    ] ] ;

:: Rz ( ANGLE -- Rz )
  
  [let | ANGLE [ ANGLE deg>rad ] |

    [let | A [ ANGLE cos     ]
           B [ ANGLE sin neg ]
           C [ ANGLE sin     ]
           D [ ANGLE cos     ] |

      { { A B 0 }
        { C D 0 }
        { 0 0 1 } }

    ] ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: apply-rotation ( TURTLE ROTATION -- turtle )
  
  TURTLE  TURTLE ori>> ROTATION m.  >>ori ;

: rotate-x ( turtle angle -- turtle ) Rx apply-rotation ;
: rotate-y ( turtle angle -- turtle ) Ry apply-rotation ;
: rotate-z ( turtle angle -- turtle ) Rz apply-rotation ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pitch-up   ( turtle angle -- turtle ) neg rotate-x ;
: pitch-down ( turtle angle -- turtle )     rotate-x ;

: turn-left  ( turtle angle -- turtle )     rotate-y ;
: turn-right ( turtle angle -- turtle ) neg rotate-y ;

: roll-left  ( turtle angle -- turtle ) neg rotate-z ;
: roll-right ( turtle angle -- turtle )     rotate-z ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: V ( -- V ) { 0 1 0 } ;

: X ( turtle -- 3array ) ori>> [ first  ] map ;
: Y ( turtle -- 3array ) ori>> [ second ] map ;
: Z ( turtle -- 3array ) ori>> [ third  ] map ;

: set-X ( turtle seq -- turtle ) over ori>> [ set-first  ] 2each ;
: set-Y ( turtle seq -- turtle ) over ori>> [ set-second ] 2each ;
: set-Z ( turtle seq -- turtle ) over ori>> [ set-third  ] 2each ;

:: roll-until-horizontal ( TURTLE -- turtle )

  TURTLE
  
    V         TURTLE Z  cross normalize  set-X

    TURTLE Z  TURTLE X  cross normalize  set-Y ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: strafe-up ( TURTLE LENGTH -- turtle )
  TURTLE 90 pitch-up LENGTH step-turtle 90 pitch-down ;

:: strafe-down ( TURTLE LENGTH -- turtle )
  TURTLE 90 pitch-down LENGTH step-turtle 90 pitch-up ;

:: strafe-left ( TURTLE LENGTH -- turtle )
  TURTLE 90 turn-left LENGTH step-turtle 90 turn-right ;

:: strafe-right ( TURTLE LENGTH -- turtle )
  TURTLE 90 turn-right LENGTH step-turtle 90 turn-left ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: polygon ( vertices -- ) GL_POLYGON glBegin [ first3 glVertex3d ] each glEnd ;

: start-polygon ( turtle -- turtle ) dup vertices>> delete-all ;

: finish-polygon ( turtle -- turtle ) dup vertices>> polygon ;

: polygon-vertex ( turtle -- turtle ) dup [ pos>> ] [ vertices>> ] bi push ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: record-vertex ( turtle -- turtle ) dup pos>> first3 glVertex3d ;

: draw-forward ( turtle length -- turtle )
  GL_LINES glBegin [ record-vertex ] dip step-turtle record-vertex glEnd ;

: move-forward ( turtle length -- turtle ) step-turtle polygon-vertex ;

: sneak-forward ( turtle length -- turtle ) step-turtle ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scale-length ( turtle m -- turtle ) over length>> * >>length ;
: scale-angle  ( turtle m -- turtle ) over angle>>  * >>angle  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: set-thickness ( turtle i -- turtle ) dup glLineWidth >>thickness ;

: scale-thickness ( turtle m -- turtle )
  over thickness>> * 0.5 max set-thickness ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: color-table ( -- colors )
  {
    T{ rgba f 0    0    0    1 } ! black
    T{ rgba f 0.5  0.5  0.5  1 } ! grey
    T{ rgba f 1    0    0    1 } ! red
    T{ rgba f 1    1    0    1 } ! yellow
    T{ rgba f 0    1    0    1 } ! green
    T{ rgba f 0.25 0.88 0.82 1 } ! turquoise
    T{ rgba f 0    0    1    1 } ! blue
    T{ rgba f 0.63 0.13 0.94 1 } ! purple
    T{ rgba f 0.00 0.50 0.00 1 } ! dark green
    T{ rgba f 0.00 0.82 0.82 1 } ! dark turquoise
    T{ rgba f 0.00 0.00 0.50 1 } ! dark blue
    T{ rgba f 0.58 0.00 0.82 1 } ! dark purple
    T{ rgba f 0.50 0.00 0.00 1 } ! dark red
    T{ rgba f 0.25 0.25 0.25 1 } ! dark grey
    T{ rgba f 0.75 0.75 0.75 1 } ! medium grey
    T{ rgba f 1    1    1    1 } ! white
  } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : material-color ( color -- )
!   GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE rot gl-material ;

: material-color ( color -- )
  GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE rot color>raw 4array gl-material ;

: set-color ( turtle i -- turtle )
  dup color-table nth dup gl-color material-color >>color ;

: inc-color ( turtle -- turtle ) dup color>> 1 + set-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: save-turtle    ( turtle -- turtle ) dup clone over saved>> push ;

: restore-turtle ( turtle -- turtle ) saved>> pop dup color>> set-color ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: default-L-parser-values ( turtle -- turtle )
  1 >>length 45 >>angle 1 >>thickness 2 >>color ;

: L-parser-dialect ( -- commands )

  {
      { "+" [ dup angle>> turn-left  ] }
      { "-" [ dup angle>> turn-right ] }
      { "&" [ dup angle>> pitch-down ] }
      { "^" [ dup angle>> pitch-up   ] }
      { "<" [ dup angle>> roll-left  ] }
      { ">" [ dup angle>> roll-right ] }

      { "|" [ 180.0         rotate-y ] }
      { "%" [ 180.0         rotate-z ] }
      { "$" [ roll-until-horizontal  ]  }

      { "F" [ dup length>>     draw-forward  ] }
      { "Z" [ dup length>> 2 / draw-forward  ] }
      { "f" [ dup length>>     move-forward  ] }
      { "z" [ dup length>> 2 / move-forward  ] }
      { "g" [ dup length>>     sneak-forward ] }
      { "." [ polygon-vertex                 ] }

      { "[" [ save-turtle      ] }
      { "]" [ restore-turtle   ] }
      
      { "{" [ start-polygon    ] }
      { "}" [ finish-polygon   ] }

      { "/" [ 1.1 scale-length    ] } ! double quote command in lparser
      { "'" [ 0.9 scale-length    ] }
      { ";" [ 1.1 scale-angle     ] }
      { ":" [ 0.9 scale-angle     ] }
      { "?" [ 1.4 scale-thickness ] }
      { "!" [ 0.7 scale-thickness ] }

      { "c" [ dup color>> 1 + color-table length mod set-color ] }

    }
    ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: <L-system> < gadget
  camera display-list pedestal paused
  turtle-values
  commands axiom rules string ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-system ( GADGET -- ) GADGET pedestal>> 0.5 + GADGET pedestal<< ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: start-rotation-thread ( GADGET -- )
  GADGET f >>paused drop
  [
    [
      GADGET paused>>
        [ f ]
        [ GADGET iterate-system GADGET relayout-1 25 milliseconds sleep t ]
      if
    ]
    loop
  ]
  in-thread ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: open-paren  ( -- ch ) CHAR: ( ;
: close-paren ( -- ch ) CHAR: ) ;

: open-paren?  ( obj -- ? ) open-paren  = ;
: close-paren? ( obj -- ? ) close-paren = ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: read-instruction ( STRING -- next rest )
  
  { [ STRING length 1 > ] [ STRING second open-paren? ] } 0&&
    [ STRING  close-paren STRING index 1 + cut ]
    [ STRING  1                            cut ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-string-loop ( STRING RULES ACCUM -- )
  STRING empty? not
    [
      STRING read-instruction
    
      [let | REST [ ] NEXT [ ] |

        NEXT 1 head RULES at  NEXT  or  ACCUM push-all

        REST RULES ACCUM iterate-string-loop ]
    ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-string ( STRING RULES -- string )

  [let | ACCUM [ STRING length  10 *  <sbuf> ] |

    STRING RULES ACCUM iterate-string-loop

    ACCUM >string ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: interpret-string ( STRING COMMANDS -- )

  STRING empty? not
    [
      STRING read-instruction

      [let | REST [ ] NEXT [ ] |

        [let | COMMAND [ NEXT 1 head COMMANDS at ] |

          COMMAND
            [
              NEXT length 1 =
                [ COMMAND call ]
                [
                  NEXT 2 tail 1 head* string>number
                  COMMAND 1 tail*
                  call
                ]
              if
            ]
          when ]

        REST COMMANDS interpret-string ]
    ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: iterate-L-system-string ( L-SYSTEM -- )
  L-SYSTEM string>> L-SYSTEM axiom>> or
  L-SYSTEM rules>>
  iterate-string
  L-SYSTEM string<< ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: do-camera-look-at ( CAMERA -- )

  [let | EYE   [ CAMERA pos>> ]
         FOCUS [ CAMERA clone 1 step-turtle pos>> ]
         UP    [ CAMERA clone 90 pitch-up 1 step-turtle pos>> CAMERA pos>> v- ]
       |

    EYE FOCUS UP gl-look-at ] ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: generate-display-list ( L-SYSTEM -- )

  L-SYSTEM find-gl-context

  L-SYSTEM display-list>> GL_COMPILE glNewList

    turtle
    L-SYSTEM turtle-values>> [ ] or call
    L-SYSTEM string>> L-SYSTEM axiom>> or
    L-SYSTEM commands>>
    interpret-string
    drop

  glEndList ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <L-system> draw-gadget* ( L-SYSTEM -- )

  black gl-clear

  GL_FLAT glShadeModel

  GL_PROJECTION glMatrixMode
  glLoadIdentity
  -1 1 -1 1 1.5 200 glFrustum

  GL_MODELVIEW glMatrixMode

  glLoadIdentity

  L-SYSTEM camera>> do-camera-look-at

  GL_FRONT_AND_BACK GL_LINE glPolygonMode

  ! draw axis
  white gl-color GL_LINES glBegin { 0 0 0 } gl-vertex { 0 0 1 } gl-vertex glEnd

  ! rotate pedestal

  L-SYSTEM pedestal>> 0 0 1 glRotated
  
  L-SYSTEM display-list>> glCallList ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <L-system> graft* ( L-SYSTEM -- )

  L-SYSTEM find-gl-context

  1 glGenLists L-SYSTEM display-list<< ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M:: <L-system> pref-dim* ( L-SYSTEM -- dim ) { 400 400 } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: with-camera ( L-SYSTEM QUOT -- )
  L-SYSTEM camera>> QUOT call drop
  L-SYSTEM relayout-1 ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<L-system>
H{
  { T{ key-down f f "LEFT"  } [ [  5 turn-left   ] with-camera ] }
  { T{ key-down f f "RIGHT" } [ [  5 turn-right  ] with-camera ] }
  { T{ key-down f f "UP"    } [ [  5 pitch-down  ] with-camera ] }
  { T{ key-down f f "DOWN"  } [ [  5 pitch-up    ] with-camera ] }
  
  { T{ key-down f f "a"     } [ [  1 step-turtle ] with-camera ] }
  { T{ key-down f f "z"     } [ [ -1 step-turtle ] with-camera ] }

  { T{ key-down f f "q"     } [ [ 5 roll-left    ] with-camera ] }
  { T{ key-down f f "w"     } [ [ 5 roll-right   ] with-camera ] }

  { T{ key-down f { A+ } "LEFT"  } [ [ 1 strafe-left  ] with-camera ] }
  { T{ key-down f { A+ } "RIGHT" } [ [ 1 strafe-right ] with-camera ] }
  { T{ key-down f { A+ } "UP"    } [ [ 1 strafe-up    ] with-camera ] }
  { T{ key-down f { A+ } "DOWN"  } [ [ 1 strafe-down  ] with-camera ] }

  { T{ key-down f f "r"     } [ start-rotation-thread          ] }

  {
    T{ key-down f f "x" }
    [
      dup iterate-L-system-string
      dup generate-display-list
      dup relayout-1
      drop
    ]
  }

  { T{ key-down f f "F1" } [ drop "L-system" help-window ] }
    
}
set-gestures

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: L-system ( -- L-system )

  <L-system> new-gadget

    0 >>pedestal
  
    ! turtle 45 turn-left 45 pitch-up 5 step-turtle 180 turn-left >>camera ;

    turtle 90 pitch-down -5 step-turtle 2 strafe-up >>camera

    dup start-rotation-thread

  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "L-system" "L-system"

"Press 'x' to iterate the L-system." $nl

"Camera control:"

{ $table

  { "a" "Forward" }
  { "z" "Backward" }

  { "LEFT" "Turn left" }
  { "RIGHT" "Turn right" }
  { "UP" "Pitch down" }
  { "DOWN" "Pitch up" }

  { "q" "Roll left" }
  { "w" "Roll right" } } ;

ABOUT: "L-system"
