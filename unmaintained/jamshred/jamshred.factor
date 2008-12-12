! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar jamshred.game jamshred.gl jamshred.player jamshred.log kernel math math.constants math.geometry.rect math.vectors namespaces sequences threads ui ui.backend ui.gadgets ui.gadgets.worlds ui.gestures ui.render ;
IN: jamshred

TUPLE: jamshred-gadget < gadget { jamshred jamshred } last-hand-loc ;

: <jamshred-gadget> ( jamshred -- gadget )
    jamshred-gadget new-gadget swap >>jamshred ;

: default-width ( -- x ) 800 ;
: default-height ( -- y ) 600 ;

M: jamshred-gadget pref-dim*
    drop default-width default-height 2array ;

M: jamshred-gadget draw-gadget* ( gadget -- )
    [ jamshred>> ] [ rect-dim first2 draw-jamshred ] bi ;

: jamshred-loop ( gadget -- )
    dup jamshred>> quit>> [
        drop
    ] [
        [ jamshred>> jamshred-update ]
        [ relayout-1 ]
        [ 10 milliseconds sleep yield jamshred-loop ] tri
    ] if ;

: fullscreen ( gadget -- )
    find-world t swap set-fullscreen* ;

: no-fullscreen ( gadget -- )
    find-world f swap set-fullscreen* ;

: toggle-fullscreen ( world -- )
    [ fullscreen? not ] keep set-fullscreen* ;

M: jamshred-gadget graft* ( gadget -- )
    [ jamshred-loop ] curry in-thread ;

M: jamshred-gadget ungraft* ( gadget -- )
    jamshred>> t swap (>>quit) ;

: jamshred-restart ( jamshred-gadget -- )
    <jamshred> >>jamshred drop ;

: pix>radians ( n m -- theta )
    / pi 4 * * ; ! 2 / / pi 2 * * ;

: x>radians ( x gadget -- theta )
    #! translate motion of x pixels to an angle
    rect-dim first pix>radians neg ;

: y>radians ( y gadget -- theta )
    #! translate motion of y pixels to an angle
    rect-dim second pix>radians ;

: (handle-mouse-motion) ( jamshred-gadget mouse-motion -- )
    over jamshred>> >r
    [ first swap x>radians ] 2keep second swap y>radians
    r> mouse-moved ;
    
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
    [ no-fullscreen ] [ close-window ] bi ;

jamshred-gadget H{
    { T{ key-down f f "r" } [ jamshred-restart ] }
    { T{ key-down f f " " } [ jamshred>> toggle-running ] }
    { T{ key-down f f "f" } [ find-world toggle-fullscreen ] }
    { T{ key-down f f "UP" } [ jamshred>> jamshred-player 1 swap change-player-speed ] }
    { T{ key-down f f "DOWN" } [ jamshred>> jamshred-player -1 swap change-player-speed ] }
    { T{ key-down f f "LEFT" } [ jamshred>> 1 jamshred-roll ] }
    { T{ key-down f f "RIGHT" } [ jamshred>> -1 jamshred-roll ] }
    { T{ key-down f f "q" } [ quit ] }
    { T{ motion } [ handle-mouse-motion ] }
    { T{ mouse-scroll } [ handle-mouse-scroll ] }
} set-gestures

: jamshred-window ( -- gadget )
    [ <jamshred> <jamshred-gadget> dup "Jamshred" open-window ] with-ui ;

MAIN: jamshred-window
