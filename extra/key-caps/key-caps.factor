USING: game-input game-input.scancodes
kernel ui.gadgets ui.gadgets.buttons sequences accessors
words arrays assocs math calendar fry alarms ui
ui.gadgets.borders ui.gestures ;
IN: key-caps

CONSTANT: key-locations H{
    { key-escape        { {   0   0 } {  10  10 } } }

    { key-f1            { {  20   0 } {  10  10 } } }
    { key-f2            { {  30   0 } {  10  10 } } }
    { key-f3            { {  40   0 } {  10  10 } } }
    { key-f4            { {  50   0 } {  10  10 } } }

    { key-f5            { {  65   0 } {  10  10 } } }
    { key-f6            { {  75   0 } {  10  10 } } }
    { key-f7            { {  85   0 } {  10  10 } } }
    { key-f8            { {  95   0 } {  10  10 } } }

    { key-f9            { { 110   0 } {  10  10 } } }
    { key-f10           { { 120   0 } {  10  10 } } }
    { key-f11           { { 130   0 } {  10  10 } } }
    { key-f12           { { 140   0 } {  10  10 } } }


    { key-`             { {   0  15 } {  10  10 } } }
    { key-1             { {  10  15 } {  10  10 } } }
    { key-2             { {  20  15 } {  10  10 } } }
    { key-3             { {  30  15 } {  10  10 } } }
    { key-4             { {  40  15 } {  10  10 } } }
    { key-5             { {  50  15 } {  10  10 } } }
    { key-6             { {  60  15 } {  10  10 } } }
    { key-7             { {  70  15 } {  10  10 } } }
    { key-8             { {  80  15 } {  10  10 } } }
    { key-9             { {  90  15 } {  10  10 } } }
    { key-0             { { 100  15 } {  10  10 } } }
    { key--             { { 110  15 } {  10  10 } } }
    { key-=             { { 120  15 } {  10  10 } } }
    { key-backspace     { { 130  15 } {  20  10 } } }

    { key-tab           { {   0  25 } {  15  10 } } }
    { key-q             { {  15  25 } {  10  10 } } }
    { key-w             { {  25  25 } {  10  10 } } }
    { key-e             { {  35  25 } {  10  10 } } }
    { key-r             { {  45  25 } {  10  10 } } }
    { key-t             { {  55  25 } {  10  10 } } }
    { key-y             { {  65  25 } {  10  10 } } }
    { key-u             { {  75  25 } {  10  10 } } }
    { key-i             { {  85  25 } {  10  10 } } }
    { key-o             { {  95  25 } {  10  10 } } }
    { key-p             { { 105  25 } {  10  10 } } }
    { key-[             { { 115  25 } {  10  10 } } }
    { key-]             { { 125  25 } {  10  10 } } }
    { key-\             { { 135  25 } {  15  10 } } }

    { key-caps-lock     { {   0  35 } {  20  10 } } }
    { key-a             { {  20  35 } {  10  10 } } }
    { key-s             { {  30  35 } {  10  10 } } }
    { key-d             { {  40  35 } {  10  10 } } }
    { key-f             { {  50  35 } {  10  10 } } }
    { key-g             { {  60  35 } {  10  10 } } }
    { key-h             { {  70  35 } {  10  10 } } }
    { key-j             { {  80  35 } {  10  10 } } }
    { key-k             { {  90  35 } {  10  10 } } }
    { key-l             { { 100  35 } {  10  10 } } }
    { key-;             { { 110  35 } {  10  10 } } }
    { key-'             { { 120  35 } {  10  10 } } }
    { key-return        { { 130  35 } {  20  10 } } }

    { key-left-shift    { {   0  45 } {  25  10 } } }
    { key-z             { {  25  45 } {  10  10 } } }
    { key-x             { {  35  45 } {  10  10 } } }
    { key-c             { {  45  45 } {  10  10 } } }
    { key-v             { {  55  45 } {  10  10 } } }
    { key-b             { {  65  45 } {  10  10 } } }
    { key-n             { {  75  45 } {  10  10 } } }
    { key-m             { {  85  45 } {  10  10 } } }
    { key-,             { {  95  45 } {  10  10 } } }
    { key-.             { { 105  45 } {  10  10 } } }
    { key-/             { { 115  45 } {  10  10 } } }
    { key-right-shift   { { 125  45 } {  25  10 } } }

    { key-left-control  { {   0  55 } {  15  10 } } }
    { key-left-gui      { {  15  55 } {  15  10 } } }
    { key-left-alt      { {  30  55 } {  15  10 } } }
    { key-space         { {  45  55 } {  45  10 } } }
    { key-right-alt     { {  90  55 } {  15  10 } } }
    { key-right-gui     { { 105  55 } {  15  10 } } }
    { key-application   { { 120  55 } {  15  10 } } }
    { key-right-control { { 135  55 } {  15  10 } } }


    { key-print-screen  { { 155   0 } {  10  10 } } }
    { key-scroll-lock   { { 165   0 } {  10  10 } } }
    { key-pause         { { 175   0 } {  10  10 } } }
    
    { key-insert        { { 155  15 } {  10  10 } } }
    { key-home          { { 165  15 } {  10  10 } } }
    { key-page-up       { { 175  15 } {  10  10 } } }

    { key-delete        { { 155  25 } {  10  10 } } }
    { key-end           { { 165  25 } {  10  10 } } }
    { key-page-down     { { 175  25 } {  10  10 } } }

    { key-up-arrow      { { 165  45 } {  10  10 } } }
    { key-left-arrow    { { 155  55 } {  10  10 } } }
    { key-down-arrow    { { 165  55 } {  10  10 } } }
    { key-right-arrow   { { 175  55 } {  10  10 } } }


    { key-keypad-numlock { { 190 15 } {  10  10 } } }
    { key-keypad-/       { { 200 15 } {  10  10 } } }
    { key-keypad-*       { { 210 15 } {  10  10 } } }
    { key-keypad--       { { 220 15 } {  10  10 } } }

    { key-keypad-7       { { 190 25 } {  10  10 } } }
    { key-keypad-8       { { 200 25 } {  10  10 } } }
    { key-keypad-9       { { 210 25 } {  10  10 } } }
    { key-keypad-+       { { 220 25 } {  10  20 } } }

    { key-keypad-4       { { 190 35 } {  10  10 } } }
    { key-keypad-5       { { 200 35 } {  10  10 } } }
    { key-keypad-6       { { 210 35 } {  10  10 } } }

    { key-keypad-1       { { 190 45 } {  10  10 } } }
    { key-keypad-2       { { 200 45 } {  10  10 } } }
    { key-keypad-3       { { 210 45 } {  10  10 } } }
    { key-keypad-enter   { { 220 45 } {  10  20 } } }

    { key-keypad-0       { { 190 55 } {  20  10 } } }
    { key-keypad-.       { { 210 55 } {  10  10 } } }
}

CONSTANT: KEYBOARD-SIZE { 230 65 }
: FREQUENCY ( -- f ) 30 recip seconds ;

TUPLE: key-caps-gadget < gadget keys alarm ;

: make-key-gadget ( scancode dim array -- )
    [ 
        swap [ 
            " " [ drop ] <border-button>
            swap [ first >>loc ] [ second >>dim ] bi
        ] [ execute( -- value ) ] bi*
    ] dip set-nth ;

: add-keys-gadgets ( gadget -- gadget )
    key-locations 256 f <array>
    [ [ make-key-gadget ] curry assoc-each ]
    [ [ [ add-gadget ] when* ] each ] 
    [ >>keys ] tri ;

: <key-caps-gadget> ( -- gadget )
    key-caps-gadget new
    add-keys-gadgets ;

M: key-caps-gadget pref-dim* drop KEYBOARD-SIZE ;

: update-key-caps-state ( gadget -- )
    read-keyboard keys>> over keys>> 
    [ [ (>>selected?) ] [ drop ] if* ] 2each 
    relayout-1 ;

M: key-caps-gadget graft*
    dup '[ _ update-key-caps-state ] FREQUENCY every >>alarm
    drop ;

M: key-caps-gadget ungraft*
    alarm>> [ cancel-alarm ] when* ;

M: key-caps-gadget handle-gesture
    drop [ key-down? ] [ key-up? ] bi or not ;

: key-caps ( -- )
    [
        open-game-input
        <key-caps-gadget> { 5 5 } <border> "Key Caps" open-window
    ] with-ui ;

MAIN: key-caps
