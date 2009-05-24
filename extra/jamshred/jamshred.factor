! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar jamshred.game jamshred.gl jamshred.player jamshred.log kernel math math.constants math.rectangles math.vectors namespaces sequences threads ui ui.backend ui.gadgets ui.gadgets.worlds ui.gestures ui.render ;
IN: jamshred

TUPLE: jamshred-gadget < gadget { jamshred jamshred } last-hand-loc ;

: <jamshred-gadget> ( jamshred -- gadget )
    jamshred-gadget new swap >>jamshred ;

CONSTANT: default-width 800
CONSTANT: default-height 600

M: jamshred-gadget pref-dim*
    drop default-width default-height 2array ;

M: jamshred-gadget draw-gadget* ( gadget -- )
    [ jamshred>> ] [ dim>> first2 draw-jamshred ] bi ;

: jamshred-loop ( gadget -- )
    dup jamshred>> quit>> [
        drop
    ] [
        [ jamshred>> jamshred-update ]
        [ relayout-1 ]
        [ 100 milliseconds sleep jamshred-loop ] tri 
    ] if ;

M: jamshred-gadget graft* ( gadget -- )
    [ find-gl-context init-graphics ]
    [ [ jamshred-loop ] curry in-thread ] bi ;

M: jamshred-gadget ungraft* ( gadget -- )
    dup find-gl-context cleanup-graphics jamshred>> t swap (>>quit) ;

: jamshred-restart ( jamshred-gadget -- )
    <jamshred> >>jamshred drop ;

: pix>radians ( n m -- theta )
    / pi 4 * * ; ! 2 / / pi 2 * * ;

: x>radians ( x gadget -- theta )
    #! translate motion of x pixels to an angle
    dim>> first pix>radians neg ;

: y>radians ( y gadget -- theta )
    #! translate motion of y pixels to an angle
    dim>> second pix>radians ;

: (handle-mouse-motion) ( jamshred-gadget mouse-motion -- )
    dupd [ first swap x>radians ] [ second swap y>radians ] 2bi
    rot jamshred>> mouse-moved ;
    
: handle-mouse-motion ( jamshred-gadget -- )
    hand-loc get [
        over last-hand-loc>> [
            v- (handle-mouse-motion) 
        ] [ 2drop ] if* 
    ] 2keep >>last-hand-loc drop ;

: handle-mouse-scroll ( jamshred-gadget -- )
    jamshred>> scroll-direction get
    [ first mouse-scroll-x ]
    [ second mouse-scroll-y ] 2bi ;

: quit ( gadget -- )
    [ f set-fullscreen ] [ close-window ] bi ;

jamshred-gadget H{
    { T{ key-down f f "r" } [ jamshred-restart ] }
    { T{ key-down f f " " } [ jamshred>> toggle-running ] }
    { T{ key-down f f "f" } [ toggle-fullscreen ] }
    { T{ key-down f f "UP" } [ jamshred>> jamshred-player 1 swap change-player-speed ] }
    { T{ key-down f f "DOWN" } [ jamshred>> jamshred-player -1 swap change-player-speed ] }
    { T{ key-down f f "LEFT" } [ jamshred>> 1 jamshred-roll ] }
    { T{ key-down f f "RIGHT" } [ jamshred>> -1 jamshred-roll ] }
    { T{ key-down f f "q" } [ quit ] }
    { motion [ handle-mouse-motion ] }
    { mouse-scroll [ handle-mouse-scroll ] }
} set-gestures

: jamshred-window ( -- )
    [ <jamshred> <jamshred-gadget> "Jamshred" open-window ] with-ui ;

MAIN: jamshred-window
