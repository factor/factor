! Copyright (C) 2007, 2008 Alex Chapman
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar jamshred.game jamshred.gl jamshred.log kernel math math.constants namespaces sequences threads ui ui.gadgets ui.gestures ui.render math.vectors ;
IN: jamshred

TUPLE: jamshred-gadget jamshred last-hand-loc alarm ;

: <jamshred-gadget> ( jamshred -- gadget )
    jamshred-gadget construct-gadget swap >>jamshred ;

: default-width ( -- x ) 640 ;
: default-height ( -- y ) 480 ;

M: jamshred-gadget pref-dim*
    drop default-width default-height 2array ;

M: jamshred-gadget draw-gadget* ( gadget -- )
    [ jamshred>> ] [ rect-dim first2 draw-jamshred ] bi ;

: jamshred-loop ( gadget -- )
    dup jamshred>> quit>> [
        drop
    ] [
        dup [ jamshred>> jamshred-update ]
        [ relayout-1 ] bi
        50 sleep jamshred-loop
    ] if ;

M: jamshred-gadget graft* ( gadget -- )
    [ jamshred-loop ] in-thread drop ;
M: jamshred-gadget ungraft* ( gadget -- )
    jamshred>> t >>quit drop ;

: jamshred-restart ( jamshred-gadget -- )
    <jamshred> >>jamshred drop ;

: pix>radians ( n m -- theta )
    2 / / pi 2 * * ;

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

jamshred-gadget H{
    { T{ key-down f f "r" } [ jamshred-restart ] }
    { T{ key-down f f " " } [ jamshred>> toggle-running ] }
    { T{ motion } [ handle-mouse-motion ] }
} set-gestures

: jamshred-window ( -- )
    [ <jamshred> <jamshred-gadget> "Jamshred" open-window ] with-ui ;

MAIN: jamshred-window
