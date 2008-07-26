USING: ui ui.gadgets sequences kernel arrays math colors
ui.render math.vectors accessors fry ui.gadgets.packs game-input
game-input.backend ui.gadgets.labels ui.gadgets.borders alarms
calendar locals combinators.lib strings ui.gadgets.buttons
combinators math.parser ;
IN: joystick-demo

: SIZE { 151 151 } ;
: ZSIZE 75 ;
: INDICATOR-SIZE { 4 4 } ;
: FREQUENCY ( -- f ) 30 recip seconds ;

TUPLE: axis-gadget < gadget indicator z-indicator ;

M: axis-gadget pref-dim* drop SIZE ;

: (rect-polygon) ( lo hi -- polygon )
    2dup
    [ [ second ] [ first  ] bi* swap 2array ]
    [ [ first  ] [ second ] bi*      2array ] 2bi swapd 4array ;

: indicator-polygon ( -- polygon )
    { 0 0 } INDICATOR-SIZE (rect-polygon) ;

: <indicator-gadget> ( color -- indicator )
    indicator-polygon <polygon-gadget> ;

: (xy>loc) ( x y -- xyloc )
    2array 0.5 v*n { 0.5 0.5 } v+ SIZE v* [ >integer ] map
    INDICATOR-SIZE 2 v/n v- ;

: (z>loc) ( xyloc z -- xyloc zloc )
    ZSIZE * >integer 0 swap 2array dupd v+ ;

: (xyz>loc) ( x y z -- xyloc zloc )
    [ [ 0.0 ] unless* ] tri@
    [ (xy>loc) ] dip (z>loc) ;

: move-axis ( gadget x y z -- )
    (xyz>loc) rot
    [ indicator>>   (>>loc) ]
    [ z-indicator>> (>>loc) ] bi+ bi* ;

: <axis-gadget> ( -- gadget )
    axis-gadget new-gadget
    gray <indicator-gadget> [ >>indicator   ] [ add-gadget ] bi
    red  <indicator-gadget> [ >>z-indicator ] [ add-gadget ] bi
    dup 0.0 0.0 0.0 move-axis ;

TUPLE: joystick-demo-gadget < pack axis raxis controller buttons alarm ;

: add-gadget-with-border ( parent child -- parent )
    2 <border> gray <solid> >>boundary add-gadget ;

: add-controller-label ( gadget controller -- gadget )
    [ >>controller ] [ product-string <label> add-gadget ] bi ;

: add-axis-gadget ( gadget shelf -- gadget shelf )
    <axis-gadget> [ >>axis ] [ add-gadget-with-border ] bi+ bi* ;

: add-raxis-gadget ( gadget shelf -- gadget shelf )
    <axis-gadget> [ >>raxis ] [ add-gadget-with-border ] bi+ bi* ;

:: (add-button-gadgets) ( gadget shelf -- )
    gadget controller>> read-controller buttons>> length [
        number>string [ ] <bevel-button>
        shelf over add-gadget drop
    ] map gadget (>>buttons) ;

: add-button-gadgets ( gadget shelf -- gadget shelf )
    [ (add-button-gadgets) ] 2keep ;

: <joystick-demo-gadget> ( controller -- gadget )
    joystick-demo-gadget new-gadget
    { 0 1 } >>orientation
    swap add-controller-label
    <shelf> add-axis-gadget add-raxis-gadget add-gadget
    <shelf> add-button-gadgets add-gadget ;

: update-buttons ( buttons button-states -- )
    [ >>selected? drop ] 2each ;

: kill-update-axes ( gadget -- )
    gray <solid> >>interior
    [ cancel-alarm f ] change-alarm
    relayout-1 ;

: (update-axes) ( gadget controller-state -- )
    {
        [ [ axis>>  ] [ [ x>>  ] [ y>>  ] [ z>>  ] tri ] bi* move-axis ]
        [ [ raxis>> ] [ [ rx>> ] [ ry>> ] [ rz>> ] tri ] bi* move-axis ]
        [ [ buttons>> ] [ buttons>> ] bi* update-buttons ]
        [ drop relayout-1 ]
    } 2cleave ;

: update-axes ( gadget -- )
    dup controller>> read-controller
    [ (update-axes) ] [ kill-update-axes ] if* ;

M: joystick-demo-gadget graft*
    dup '[ , update-axes ] FREQUENCY every >>alarm
    drop ;

M: joystick-demo-gadget ungraft*
    alarm>> [ cancel-alarm ] when* ;

: joystick-window ( controller -- )
    [ <joystick-demo-gadget> ] [ product-string ] bi
    open-window ;

: joystick-demo ( -- )
    [
        open-game-input
        get-controllers [ joystick-window ] each
    ] with-ui ;

MAIN: joystick-demo
