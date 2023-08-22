! Copyright (C) 2016 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs kernel literals ui.gestures x11.X
x11.keysymdef ;
IN: ui.backend.x11.keys

CONSTANT: modifiers
    {
        ${ S+ ShiftMask }
        ${ C+ ControlMask }
        ${ A+ Mod1Mask }
        ${ M+ Mod4Mask }
    }

CONSTANT: codes
    H{
        { $ XK_BackSpace "BACKSPACE" }
        { $ XK_Tab "TAB" }
        { $ XK_ISO_Left_Tab "TAB" }
        { $ XK_Return "RET" }
        { $ XK_KP_Enter "ENTER" }
        { $ XK_Escape "ESC" }
        { $ XK_Delete "DELETE" }
        { $ XK_KP_Delete "DELETE" }
        { $ XK_Insert "INSERT" }
        { $ XK_KP_Insert "INSERT" }
        { $ XK_Home "HOME" }
        { $ XK_KP_Home "HOME" }
        { $ XK_Left "LEFT" }
        { $ XK_KP_Left "LEFT" }
        { $ XK_Up "UP" }
        { $ XK_KP_Up "UP" }
        { $ XK_Right "RIGHT" }
        { $ XK_KP_Right "RIGHT" }
        { $ XK_Down "DOWN" }
        { $ XK_KP_Down "DOWN" }
        { $ XK_Page_Up "PAGE_UP" }
        { $ XK_KP_Page_Up "PAGE_UP" }
        { $ XK_Page_Down "PAGE_DOWN" }
        { $ XK_KP_Page_Down "PAGE_DOWN" }
        { $ XK_End "END" }
        { $ XK_KP_End "END" }
        { $ XK_Begin "BEGIN" }
        { $ XK_KP_Begin "BEGIN" }
        { $ XK_F1 "F1" }
        { $ XK_F2 "F2" }
        { $ XK_F3 "F3" }
        { $ XK_F4 "F4" }
        { $ XK_F5 "F5" }
        { $ XK_F6 "F6" }
        { $ XK_F7 "F7" }
        { $ XK_F8 "F8" }
        { $ XK_F9 "F9" }
        { $ XK_F10 "F10" }
        { $ XK_F11 "F11" }
        { $ XK_F12 "F12" }

        { $ XK_Shift_L f }
        { $ XK_Shift_R f }
        { $ XK_Control_L f }
        { $ XK_Control_R f }
        { $ XK_Caps_Lock f }
        { $ XK_Shift_Lock f }

        { $ XK_Meta_L f }
        { $ XK_Meta_R f }
        { $ XK_Alt_L f }
        { $ XK_Alt_R f }
        { $ XK_Super_L f }
        { $ XK_Super_R f }
        { $ XK_Hyper_L f }
        { $ XK_Hyper_R f }
    }

: code>sym ( code -- name/code/f action? )
    dup codes at* [ nip dup t and ] when ;

: event-modifiers ( event -- seq )
    state>> modifiers modifier ;
