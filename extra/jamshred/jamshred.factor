USING: arrays jamshred.game jamshred.gl kernel math math.constants
namespaces sequences timers ui ui.gadgets ui.gestures ui.render
math.vectors ;
IN: jamshred

TUPLE: jamshred-gadget jamshred last-hand-loc ;

: <jamshred-gadget> ( jamshred -- gadget )
    jamshred-gadget construct-gadget tuck set-jamshred-gadget-jamshred ;

: default-width ( -- x ) 1024 ;
: default-height ( -- y ) 768 ;

M: jamshred-gadget pref-dim*
    drop default-width default-height 2array ;

M: jamshred-gadget draw-gadget* ( gadget -- )
    dup jamshred-gadget-jamshred swap rect-dim first2 draw-jamshred ;

M: jamshred-gadget tick ( gadget -- )
    dup jamshred-gadget-jamshred jamshred-update relayout-1 ;

M: jamshred-gadget graft* ( gadget -- )
     10 1 add-timer ;

M: jamshred-gadget ungraft* ( gadget -- ) remove-timer ;

: jamshred-restart ( jamshred-gadget -- )
    <jamshred> swap set-jamshred-gadget-jamshred ;

: pix>radians ( n m -- theta )
    2 / / pi * ;

: x>radians ( x gadget -- theta )
    #! translate motion of x pixels to an angle
    rect-dim first pix>radians neg ;

: y>radians ( y gadget -- theta )
    #! translate motion of y pixels to an angle
    rect-dim second pix>radians ;

: (handle-mouse-motion) ( jamshred-gadget mouse-motion -- )
    over jamshred-gadget-jamshred >r
    [ first swap x>radians ] 2keep second swap y>radians
    r> mouse-moved ;
    
: handle-mouse-motion ( jamshred-gadget -- )
    hand-loc get [
        over jamshred-gadget-last-hand-loc [
            v- (handle-mouse-motion) 
        ] [ 2drop ] if* 
    ] 2keep swap set-jamshred-gadget-last-hand-loc ;

USE: vocabs.loader
jamshred-gadget H{
    { T{ key-down f f "r" } [ jamshred-restart refresh-all ] }
    { T{ key-down f f " " } [ jamshred-gadget-jamshred toggle-running ] }
    { T{ motion } [ handle-mouse-motion ] }
} set-gestures

: jamshred-window ( -- )
    [ <jamshred> <jamshred-gadget> "Jamshred" open-window ] with-ui ;

MAIN: jamshred-window
