
USING: kernel sequences math math.order
       ui.gadgets ui.gadgets.tracks ui.gestures
       fry accessors ;

IN: ui.gadgets.tiling

TUPLE: tiling < track gadgets columns first focused ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-tiling ( tiling -- tiling )
  init-track
  { 1 0 }    >>orientation
  V{ } clone >>gadgets
  2          >>columns
  0          >>first
  0          >>focused ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <tiling> ( -- gadget )
  tiling new
  init-tiling ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bounded-subseq ( seq a b -- seq )
  [ 0 max ] dip
  pick length [ min ] curry bi@
  rot
  subseq ;

: tiling-gadgets-to-map ( tiling -- gadgets )
  [ gadgets>> ]
  [ first>> ]
  [ [ first>> ] [ columns>> ] bi + ]
  tri
  bounded-subseq ;

: tiling-map-gadgets ( tiling -- tiling )
  dup clear-track
  dup tiling-gadgets-to-map [ 1 track-add* ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: tiling-add ( tiling gadget -- tiling )
  over gadgets>> push
  tiling-map-gadgets ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: first-gadget ( tiling -- index ) drop 0 ;

: last-gadget ( tiling -- index ) gadgets>> length 1 - ;

: first-viewable ( tiling -- index ) first>> ;

: last-viewable ( tiling -- index ) [ first>> ] [ columns>> ] bi + 1 - ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-focused-mapped ( tiling -- tiling )

  dup [ focused>> ] [ first>> ] bi <
    [ dup first>> 1 - >>first ]
    [ ]
  if

  dup [ last-viewable ] [ focused>> ] bi <
    [ dup first>> 1 + >>first ]
    [ ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: check-focused-bounds ( tiling -- tiling )
  dup focused>> 0 max over gadgets>> length 1 - min >>focused ;

: focus-left ( tiling -- tiling )
  dup focused>> 1 - >>focused
  check-focused-bounds
  make-focused-mapped
  tiling-map-gadgets
  dup request-focus ;

: focus-right ( tiling -- tiling )
  dup focused>> 1 + >>focused
  check-focused-bounds
  make-focused-mapped
  tiling-map-gadgets
  dup request-focus ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: exchanged! ( seq a b -- )
                   [ 0 max ] bi@
  pick length 1 - '[ , min ] bi@
  rot exchange ;

: move-left ( tiling -- tiling )
  dup [ gadgets>> ] [ focused>> 1 - ] [ focused>> ] tri exchanged!
  focus-left ;

: move-right ( tiling -- tiling )
  dup [ gadgets>> ] [ focused>> ] [ focused>> 1 + ] tri exchanged!
  focus-right ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-column ( tiling -- tiling )
  dup columns>> 1 + >>columns
  tiling-map-gadgets ;

: del-column ( tiling -- tiling )
  dup columns>> 1 - 1 max >>columns
  tiling-map-gadgets ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: tiling focusable-child* ( tiling -- child/t )
   [ focused>> ] [ gadgets>> ] bi nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

tiling
 H{
    { T{ key-down f { A+    } "LEFT"  } [ focus-left  drop ] }
    { T{ key-down f { A+    } "RIGHT" } [ focus-right drop ] }
    { T{ key-down f { S+ A+ } "LEFT"  } [ move-left   drop ] }
    { T{ key-down f { S+ A+ } "RIGHT" } [ move-right  drop ] }
    { T{ key-down f { C+    } "["     } [ del-column  drop ] }
    { T{ key-down f { C+    } "]"     } [ add-column  drop ] }
  }
set-gestures