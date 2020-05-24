! Copyright (C) 2016 Björn Lindqvist
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel literals ui.gestures x11.X
x11.keysymdef combinators.smart.syntax ;
IN: ui.backend.x11.keys

CONSTANT: modifiers {
        array[ S+ ShiftMask ]
        array[ C+ ControlMask ]
        array[ A+ Mod1Mask ]
        array[ M+ Mod4Mask ]
    }

CONSTANT: codes
    H{
        array[ XK_BackSpace "BACKSPACE" ]
        array[ XK_Tab "TAB" ]
        array[ XK_ISO_Left_Tab "TAB" ]
        array[ XK_Return "RET" ]
        array[ XK_KP_Enter "ENTER" ]
        array[ XK_Escape "ESC" ]
        array[ XK_Delete "DELETE" ]
        array[ XK_KP_Delete "DELETE" ]
        array[ XK_Insert "INSERT" ]
        array[ XK_KP_Insert "INSERT" ]
        array[ XK_Home "HOME" ]
        array[ XK_KP_Home "HOME" ]
        array[ XK_Left "LEFT" ]
        array[ XK_KP_Left "LEFT" ]
        array[ XK_Up "UP" ]
        array[ XK_KP_Up "UP" ]
        array[ XK_Right "RIGHT" ]
        array[ XK_KP_Right "RIGHT" ]
        array[ XK_Down "DOWN" ]
        array[ XK_KP_Down "DOWN" ]
        array[ XK_Page_Up "PAGE_UP" ]
        array[ XK_KP_Page_Up "PAGE_UP" ]
        array[ XK_Page_Down "PAGE_DOWN" ]
        array[ XK_KP_Page_Down "PAGE_DOWN" ]
        array[ XK_End "END" ]
        array[ XK_KP_End "END" ]
        array[ XK_Begin "BEGIN" ]
        array[ XK_KP_Begin "BEGIN" ]
        array[ XK_F1 "F1" ]
        array[ XK_F2 "F2" ]
        array[ XK_F3 "F3" ]
        array[ XK_F4 "F4" ]
        array[ XK_F5 "F5" ]
        array[ XK_F6 "F6" ]
        array[ XK_F7 "F7" ]
        array[ XK_F8 "F8" ]
        array[ XK_F9 "F9" ]
        array[ XK_F10 "F10" ]
        array[ XK_F11 "F11" ]
        array[ XK_F12 "F12" ]
        array[ XK_Shift_L f ]
        array[ XK_Shift_R f ]
        array[ XK_Control_L f ]
        array[ XK_Control_R f ]
        array[ XK_Caps_Lock f ]
        array[ XK_Shift_Lock f ]

        array[ XK_Meta_L f ]
        array[ XK_Meta_R f ]
        array[ XK_Alt_L f ]
        array[ XK_Alt_R f ]
        array[ XK_Super_L f ]
        array[ XK_Super_R f ]
        array[ XK_Hyper_L f ]
        array[ XK_Hyper_R f ]
    }

: code>sym ( code -- name/code/f action? )
    dup codes at* [ nip dup t and ] when ;

: event-modifiers ( event -- seq )
    state>> modifiers modifier ;
