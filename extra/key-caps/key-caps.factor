USING: game-input game-input.backend game-input.scancodes
kernel ui.gadgets ui.gadgets.buttons sequences accessors
words arrays assocs math calendar fry alarms ui
ui.gadgets.borders ;
IN: key-caps

: key-locations H{
    { key-escape        { {   0   0 } {  10  10 } } }

    { key-f1            { {  15   0 } {  10  10 } } } 
    { key-f2            { {  25   0 } {  10  10 } } }
    { key-f3            { {  35   0 } {  10  10 } } }
    { key-f4            { {  45   0 } {  10  10 } } }

    { key-f5            { {  60   0 } {  10  10 } } }
    { key-f6            { {  70   0 } {  10  10 } } }
    { key-f7            { {  80   0 } {  10  10 } } }
    { key-f8            { {  90   0 } {  10  10 } } }

    { key-f9            { { 105   0 } {  10  10 } } }
    { key-f10           { { 115   0 } {  10  10 } } }
    { key-f11           { { 125   0 } {  10  10 } } }
    { key-f12           { { 135   0 } {  10  10 } } }


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
    { key-backspace     { { 130  15 } {  15  10 } } }

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
    { key-\             { { 135  25 } {  10  10 } } }

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
    { key-return        { { 130  35 } {  15  10 } } }

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
    { key-right-shift   { { 125  45 } {  20  10 } } }

    { key-left-control  { {   0  55 } {  15  10 } } }
    { key-left-gui      { {  15  55 } {  15  10 } } }
    { key-left-alt      { {  30  55 } {  15  10 } } }
    { key-space         { {  45  55 } {  55  10 } } }
    { key-right-alt     { { 100  55 } {  15  10 } } }
    { key-right-gui     { { 115  55 } {  15  10 } } }
    { key-right-control { { 130  55 } {  15  10 } } }


    { key-print-screen  { { 150   0 } {  10  10 } } }
    { key-scroll-lock   { { 160   0 } {  10  10 } } }
    { key-pause         { { 170   0 } {  10  10 } } }
    
    { key-insert        { { 150  15 } {  10  10 } } }
    { key-home          { { 160  15 } {  10  10 } } }
    { key-page-up       { { 170  15 } {  10  10 } } }

    { key-delete        { { 150  25 } {  10  10 } } }
    { key-end           { { 160  25 } {  10  10 } } }
    { key-page-down     { { 170  25 } {  10  10 } } }

    { key-up-arrow      { { 160  45 } {  10  10 } } }
    { key-left-arrow    { { 150  55 } {  10  10 } } }
    { key-down-arrow    { { 160  55 } {  10  10 } } }
    { key-right-arrow   { { 170  55 } {  10  10 } } }


    { key-keypad-numlock { { 185 15 } {  10  10 } } }
    { key-keypad-/       { { 195 15 } {  10  10 } } }
    { key-keypad-*       { { 205 15 } {  10  10 } } }
    { key-keypad--       { { 215 15 } {  10  10 } } }

    { key-keypad-7       { { 185 25 } {  10  10 } } }
    { key-keypad-8       { { 195 25 } {  10  10 } } }
    { key-keypad-9       { { 205 25 } {  10  10 } } }
    { key-keypad-+       { { 215 25 } {  10  20 } } }

    { key-keypad-4       { { 185 35 } {  10  10 } } }
    { key-keypad-5       { { 195 35 } {  10  10 } } }
    { key-keypad-6       { { 205 35 } {  10  10 } } }

    { key-keypad-1       { { 185 45 } {  10  10 } } }
    { key-keypad-2       { { 195 45 } {  10  10 } } }
    { key-keypad-3       { { 205 45 } {  10  10 } } }
    { key-keypad-enter   { { 215 45 } {  10  20 } } }

    { key-keypad-0       { { 185 55 } {  20  10 } } }
    { key-keypad-.       { { 205 55 } {  10  10 } } }
} ;

: KEYBOARD-SIZE { 225 65 } ;
: FREQUENCY ( -- f ) 30 recip seconds ;

TUPLE: key-caps-gadget < gadget keys alarm ;

: make-key-gadget ( scancode dim array -- )
    [ 
        swap [ 
            " " [ ] <bevel-button>
            swap [ first >>loc ] [ second >>dim ] bi
        ] [ execute ] bi*
    ] dip set-nth ;

: add-keys-gadgets ( gadget -- gadget )
    key-locations 256 f <array>
    [ [ make-key-gadget ] curry assoc-each ]
    [ [ [ add-gadget ] when* ] each ] 
    [ >>keys ] tri ;

: <key-caps-gadget> ( -- gadget )
    key-caps-gadget new-gadget
    add-keys-gadgets ;

M: key-caps-gadget pref-dim* drop KEYBOARD-SIZE ;

: update-key-caps-state ( gadget -- )
    read-keyboard keys>> over keys>> 
    [ [ (>>selected?) ] [ drop ] if* ] 2each 
    relayout-1 ;

M: key-caps-gadget graft*
    dup '[ , update-key-caps-state ] FREQUENCY every >>alarm
    drop ;

M: key-caps-gadget ungraft*
    alarm>> [ cancel-alarm ] when* ;

: key-caps ( -- )
    [
        open-game-input
        <key-caps-gadget> 5 <border> "Key Caps" open-window
    ] with-ui ;

MAIN: key-caps
