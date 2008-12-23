
USING: kernel sequences math math.order
       ui.gadgets ui.gadgets.tracks ui.gestures accessors fry
       help.syntax
       easy-help ;

IN: ui.gadgets.tiling

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ARTICLE: "ui.gadgets.tiling" "Tiling Layout Gadgets"

Summary:

    A gadget which tiles it's children.

    A tiling gadget may contain any number of children, but only a
    fixed number is displayed at one time. How many are displayed can
    be controlled via Control-[ and Control-].

    The focus may be switched with Alt-Left and Alt-Right.

    The focused child may be moved via Shift-Alt-Left and
    Shift-Alt-Right. ..

Example:

    <tiling-shelf>
      "resource:" directory-files
        [ [ drop ] <bevel-button> tiling-add ]
      each
    "Files" open-window ..

;

ABOUT: "ui.gadgets.tiling"

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: tiling < track gadgets tiles first focused ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: init-tiling ( tiling -- tiling )
  init-track
  { 1 0 }    >>orientation
  V{ } clone >>gadgets
  2          >>tiles
  0          >>first
  0          >>focused ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: <tiling> ( -- gadget ) tiling new init-tiling ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bounded-subseq ( seq a b -- seq )
  [ 0 max ] dip
  pick length [ min ] curry bi@
  rot
  subseq ;

: tiling-gadgets-to-map ( tiling -- gadgets )
  [ gadgets>> ]
  [ first>> ]
  [ [ first>> ] [ tiles>> ] bi + ]
  tri
  bounded-subseq ;

: tiling-map-gadgets ( tiling -- tiling )
  dup clear-track
  dup tiling-gadgets-to-map [ 1 track-add ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: tiling-add ( tiling gadget -- tiling )
  over gadgets>> push
  tiling-map-gadgets ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: first-gadget ( tiling -- index ) drop 0 ;

: last-gadget ( tiling -- index ) gadgets>> length 1 - ;

: first-viewable ( tiling -- index ) first>> ;

: last-viewable ( tiling -- index ) [ first>> ] [ tiles>> ] bi + 1 - ;

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

: focus-prev ( tiling -- tiling )
  dup focused>> 1 - >>focused
  check-focused-bounds
  make-focused-mapped
  tiling-map-gadgets
  dup request-focus ;

: focus-next ( tiling -- tiling )
  dup focused>> 1 + >>focused
  check-focused-bounds
  make-focused-mapped
  tiling-map-gadgets
  dup request-focus ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: exchanged! ( seq a b -- )
                   [ 0 max ] bi@
  pick length 1 - '[ _ min ] bi@
  rot exchange ;

: move-prev ( tiling -- tiling )
  dup [ gadgets>> ] [ focused>> 1 - ] [ focused>> ] tri exchanged!
  focus-prev ;

: move-next ( tiling -- tiling )
  dup [ gadgets>> ] [ focused>> ] [ focused>> 1 + ] tri exchanged!
  focus-next ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: add-tile ( tiling -- tiling )
  dup tiles>> 1 + >>tiles
  tiling-map-gadgets ;

: del-tile ( tiling -- tiling )
  dup tiles>> 1 - 1 max >>tiles
  tiling-map-gadgets ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

M: tiling focusable-child* ( tiling -- child/t )
   [ focused>> ] [ gadgets>> ] bi nth ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: tiling-shelf < tiling ;
TUPLE: tiling-pile  < tiling ;

: <tiling-shelf> ( -- gadget )
  tiling-shelf new init-tiling { 1 0 } >>orientation ;

: <tiling-pile> ( -- gadget )
  tiling-pile new init-tiling { 0 1 } >>orientation ;

tiling-shelf
 H{
    { T{ key-down f { A+    } "LEFT"  } [ focus-prev  drop ] }
    { T{ key-down f { A+    } "RIGHT" } [ focus-next drop ] }
    { T{ key-down f { S+ A+ } "LEFT"  } [ move-prev   drop ] }
    { T{ key-down f { S+ A+ } "RIGHT" } [ move-next  drop ] }
    { T{ key-down f { C+    } "["     } [ del-tile  drop ] }
    { T{ key-down f { C+    } "]"     } [ add-tile  drop ] }
  }
set-gestures

tiling-pile
 H{
    { T{ key-down f { A+    } "UP"  } [ focus-prev  drop ] }
    { T{ key-down f { A+    } "DOWN" } [ focus-next drop ] }
    { T{ key-down f { S+ A+ } "UP"  } [ move-prev   drop ] }
    { T{ key-down f { S+ A+ } "DOWN" } [ move-next  drop ] }
    { T{ key-down f { C+    } "["     } [ del-tile  drop ] }
    { T{ key-down f { C+    } "]"     } [ add-tile  drop ] }
  }
set-gestures
