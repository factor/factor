USING: game.input game.input.scancodes
kernel ui.gadgets ui.gadgets.buttons sequences accessors
words arrays assocs math calendar fry timers ui
ui.gadgets.borders ui.gestures literals ;
IN: game.input.demos.key-caps

CONSTANT: key-locations H{
    { key-escape         { "ESC" {   0   0 } {  30  30 } } }

    { key-f1             { "F1"  {  60   0 } {  30  30 } } }
    { key-f2             { "F2"  {  90   0 } {  30  30 } } }
    { key-f3             { "F3"  { 120   0 } {  30  30 } } }
    { key-f4             { "F4"  { 150   0 } {  30  30 } } }

    { key-f5             { "F5"  { 195   0 } {  30  30 } } }
    { key-f6             { "F6"  { 225   0 } {  30  30 } } }
    { key-f7             { "F7"  { 255   0 } {  30  30 } } }
    { key-f8             { "F8"  { 285   0 } {  30  30 } } }

    { key-f9             { "F9"  { 330   0 } {  30  30 } } }
    { key-f10            { "F10" { 360   0 } {  30  30 } } }
    { key-f11            { "F11" { 390   0 } {  30  30 } } }
    { key-f12            { "F12" { 420   0 } {  30  30 } } }


    { key-backtick       { "`"   {   0  45 } {  30  30 } } }
    { key-1              { "1"   {  30  45 } {  30  30 } } }
    { key-2              { "2"   {  60  45 } {  30  30 } } }
    { key-3              { "3"   {  90  45 } {  30  30 } } }
    { key-4              { "4"   { 120  45 } {  30  30 } } }
    { key-5              { "5"   { 150  45 } {  30  30 } } }
    { key-6              { "6"   { 180  45 } {  30  30 } } }
    { key-7              { "7"   { 210  45 } {  30  30 } } }
    { key-8              { "8"   { 240  45 } {  30  30 } } }
    { key-9              { "9"   { 270  45 } {  30  30 } } }
    { key-0              { "0"   { 300  45 } {  30  30 } } }
    { key--              { "-"   { 330  45 } {  30  30 } } }
    { key-=              { "="   { 360  45 } {  30  30 } } }
    { key-backspace      { "⌫"   { 390  45 } {  60  30 } } }

    { key-tab            { "↹"   {   0  75 } {  45  30 } } }
    { key-q              { "Q"   {  45  75 } {  30  30 } } }
    { key-w              { "W"   {  75  75 } {  30  30 } } }
    { key-e              { "E"   { 105  75 } {  30  30 } } }
    { key-r              { "R"   { 135  75 } {  30  30 } } }
    { key-t              { "T"   { 165  75 } {  30  30 } } }
    { key-y              { "Y"   { 195  75 } {  30  30 } } }
    { key-u              { "U"   { 225  75 } {  30  30 } } }
    { key-i              { "I"   { 255  75 } {  30  30 } } }
    { key-o              { "O"   { 285  75 } {  30  30 } } }
    { key-p              { "P"   { 315  75 } {  30  30 } } }
    { key-lbracket       { "["   { 345  75 } {  30  30 } } }
    { key-rbracket       { "]"   { 375  75 } {  30  30 } } }
    { key-\              { "\\"  { 405  75 } {  45  30 } } }

    { key-caps-lock      { "⇪"   {   0 105 } {  60  30 } } }
    { key-a              { "A"   {  60 105 } {  30  30 } } }
    { key-s              { "S"   {  90 105 } {  30  30 } } }
    { key-d              { "D"   { 120 105 } {  30  30 } } }
    { key-f              { "F"   { 150 105 } {  30  30 } } }
    { key-g              { "G"   { 180 105 } {  30  30 } } }
    { key-h              { "H"   { 210 105 } {  30  30 } } }
    { key-j              { "J"   { 240 105 } {  30  30 } } }
    { key-k              { "K"   { 270 105 } {  30  30 } } }
    { key-l              { "L"   { 300 105 } {  30  30 } } }
    { key-;              { ";"   { 330 105 } {  30  30 } } }
    { key-'              { "'"   { 360 105 } {  30  30 } } }
    { key-return         { "⏎"   { 390 105 } {  60  30 } } }

    { key-left-shift     { "⇧"   {   0 135 } {  75  30 } } }
    { key-z              { "Z"   {  75 135 } {  30  30 } } }
    { key-x              { "X"   { 105 135 } {  30  30 } } }
    { key-c              { "C"   { 135 135 } {  30  30 } } }
    { key-v              { "V"   { 165 135 } {  30  30 } } }
    { key-b              { "B"   { 195 135 } {  30  30 } } }
    { key-n              { "N"   { 225 135 } {  30  30 } } }
    { key-m              { "M"   { 255 135 } {  30  30 } } }
    { key-,              { ","   { 285 135 } {  30  30 } } }
    { key-.              { "."   { 315 135 } {  30  30 } } }
    { key-/              { "/"   { 345 135 } {  30  30 } } }
    { key-right-shift    { "⇧"   { 375 135 } {  75  30 } } }

    { key-left-control   { " "   {   0 165 } {  45  30 } } }
    { key-left-gui       { " "   {  45 165 } {  45  30 } } }
    { key-left-alt       { " "   {  90 165 } {  45  30 } } }
    { key-space          { "SPACE" { 135 165 } { 135  30 } } }
    { key-right-alt      { " "   { 270 165 } {  45  30 } } }
    { key-right-gui      { " "   { 315 165 } {  45  30 } } }
    { key-application    { " "   { 360 165 } {  45  30 } } }
    { key-right-control  { " "   { 405 165 } {  45  30 } } }


    { key-print-screen   { "⎙"   { 465   0 } {  30  30 } } }
    { key-scroll-lock    { " "   { 495   0 } {  30  30 } } }
    { key-pause          { " "   { 525   0 } {  30  30 } } }

    { key-insert         { "INS" { 465  45 } {  30  30 } } }
    { key-home           { "↖"   { 495  45 } {  30  30 } } }
    { key-page-up        { "⇞"   { 525  45 } {  30  30 } } }

    { key-delete         { "⌦"   { 465  75 } {  30  30 } } }
    { key-end            { "↘"   { 495  75 } {  30  30 } } }
    { key-page-down      { "⇟"   { 525  75 } {  30  30 } } }

    { key-up-arrow       { "⬆"   { 495 135 } {  30  30 } } }
    { key-left-arrow     { "⬅"   { 465 165 } {  30  30 } } }
    { key-down-arrow     { "⬇"   { 495 165 } {  30  30 } } }
    { key-right-arrow    { "➡"   { 525 165 } {  30  30 } } }


    { key-keypad-numlock { " "   { 570  45 } {  30  30 } } }
    { key-keypad-/       { "/"   { 600  45 } {  30  30 } } }
    { key-keypad-*       { "*"   { 630  45 } {  30  30 } } }
    { key-keypad--       { "-"   { 660  45 } {  30  30 } } }

    { key-keypad-7       { "7"   { 570  75 } {  30  30 } } }
    { key-keypad-8       { "8"   { 600  75 } {  30  30 } } }
    { key-keypad-9       { "9"   { 630  75 } {  30  30 } } }
    { key-keypad-+       { "+"   { 660  75 } {  30  60 } } }

    { key-keypad-4       { "4"   { 570 105 } {  30  30 } } }
    { key-keypad-5       { "5"   { 600 105 } {  30  30 } } }
    { key-keypad-6       { "6"   { 630 105 } {  30  30 } } }

    { key-keypad-1       { "1"   { 570 135 } {  30  30 } } }
    { key-keypad-2       { "2"   { 600 135 } {  30  30 } } }
    { key-keypad-3       { "3"   { 630 135 } {  30  30 } } }
    { key-keypad-enter   { "⌤"   { 660 135 } {  30  60 } } }

    { key-keypad-0       { "0"   { 570 165 } {  60  30 } } }
    { key-keypad-.       { "."   { 630 165 } {  30  30 } } }
}

CONSTANT: KEYBOARD-SIZE { 690 195 }
CONSTANT: FREQUENCY $[ 1/30 seconds ]

TUPLE: key-caps-gadget < gadget keys timer ;

: make-key-gadget ( scancode dim array -- )
    [
        swap [
            [ first [ drop ] <border-button> ]
            [ second >>loc ]
            [ third >>dim ] tri
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
    [ [ selected?<< ] [ drop ] if* ] 2each
    relayout-1 ;

M: key-caps-gadget graft*
    open-game-input
    dup '[ _ update-key-caps-state ] FREQUENCY every >>timer
    drop ;

M: key-caps-gadget ungraft*
    timer>> [ stop-timer ] when*
    close-game-input ;

M: key-caps-gadget handle-gesture
    drop [ key-down? ] [ key-up? ] bi or not ;

MAIN-WINDOW: key-caps { { title "Key Caps" } }
    <key-caps-gadget> { 5 5 } <border> >>gadgets ;
