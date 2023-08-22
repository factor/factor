! Copyright (C) 2016 Björn Lindqvist
! See https://factorcode.org/license.txt for BSD license.

! Selected parts of /usr/include/X11/keysymdef.h
IN: x11.keysymdef

! TTY function keys, cleverly chosen to map to ASCII, for convenience
! of programming, but could have been arbitrary (at the cost of lookup
! tables in client code).
CONSTANT: XK_BackSpace      0xff08  ! Back space, back char
CONSTANT: XK_Tab            0xff09
CONSTANT: XK_Linefeed       0xff0a  ! Linefeed, LF
CONSTANT: XK_Clear          0xff0b
CONSTANT: XK_Return         0xff0d  ! Return, enter
CONSTANT: XK_Pause          0xff13  ! Pause, hold
CONSTANT: XK_Scroll_Lock    0xff14
CONSTANT: XK_Sys_Req        0xff15
CONSTANT: XK_Escape         0xff1b
CONSTANT: XK_Delete         0xffff  ! Delete, rubout

! Cursor control & motion
CONSTANT: XK_Home           0xff50
CONSTANT: XK_Left           0xff51  ! Move left, left arrow
CONSTANT: XK_Up             0xff52  ! Move up, up arrow
CONSTANT: XK_Right          0xff53  ! Move right, right arrow
CONSTANT: XK_Down           0xff54  ! Move down, down arrow
CONSTANT: XK_Prior          0xff55  ! Prior, previous
CONSTANT: XK_Page_Up        0xff55
CONSTANT: XK_Next           0xff56  ! Next
CONSTANT: XK_Page_Down      0xff56
CONSTANT: XK_End            0xff57  ! EOL
CONSTANT: XK_Begin          0xff58  ! BOL

! Misc functions
CONSTANT: XK_Select         0xff60  ! Select, mark
CONSTANT: XK_Print          0xff61
CONSTANT: XK_Execute        0xff62  ! Execute, run, do
CONSTANT: XK_Insert         0xff63  ! Insert, insert here
CONSTANT: XK_Undo           0xff65
CONSTANT: XK_Redo           0xff66  ! Redo, again
CONSTANT: XK_Menu           0xff67
CONSTANT: XK_Find           0xff68  ! Find, search
CONSTANT: XK_Cancel         0xff69  ! Cancel, stop, abort, exit
CONSTANT: XK_Help           0xff6a  ! Help
CONSTANT: XK_Break          0xff6b
CONSTANT: XK_Mode_switch    0xff7e  ! Character set switch
CONSTANT: XK_script_switch  0xff7e  ! Alias for mode_switch
CONSTANT: XK_Num_Lock       0xff7f

! Keypad functions, keypad numbers cleverly chosen to map to ASCII
CONSTANT: XK_KP_Space       0xff80  ! Space
CONSTANT: XK_KP_Tab         0xff89
CONSTANT: XK_KP_Enter       0xff8d  ! Enter
CONSTANT: XK_KP_F1          0xff91  ! PF1, KP_A, ...
CONSTANT: XK_KP_F2          0xff92
CONSTANT: XK_KP_F3          0xff93
CONSTANT: XK_KP_F4          0xff94
CONSTANT: XK_KP_Home        0xff95
CONSTANT: XK_KP_Left        0xff96
CONSTANT: XK_KP_Up          0xff97
CONSTANT: XK_KP_Right       0xff98
CONSTANT: XK_KP_Down        0xff99
CONSTANT: XK_KP_Prior       0xff9a
CONSTANT: XK_KP_Page_Up     0xff9a
CONSTANT: XK_KP_Next        0xff9b
CONSTANT: XK_KP_Page_Down   0xff9b
CONSTANT: XK_KP_End         0xff9c
CONSTANT: XK_KP_Begin       0xff9d
CONSTANT: XK_KP_Insert      0xff9e
CONSTANT: XK_KP_Delete      0xff9f
CONSTANT: XK_KP_Equal       0xffbd  ! Equals
CONSTANT: XK_KP_Multiply    0xffaa
CONSTANT: XK_KP_Add         0xffab
CONSTANT: XK_KP_Separator   0xffac  ! Separator, often comma
CONSTANT: XK_KP_Subtract    0xffad
CONSTANT: XK_KP_Decimal     0xffae
CONSTANT: XK_KP_Divide      0xffaf

CONSTANT: XK_KP_0           0xffb0
CONSTANT: XK_KP_1           0xffb1
CONSTANT: XK_KP_2           0xffb2
CONSTANT: XK_KP_3           0xffb3
CONSTANT: XK_KP_4           0xffb4
CONSTANT: XK_KP_5           0xffb5
CONSTANT: XK_KP_6           0xffb6
CONSTANT: XK_KP_7           0xffb7
CONSTANT: XK_KP_8           0xffb8
CONSTANT: XK_KP_9           0xffb9

! Auxiliary functions; note the duplicate definitions for left and
! right function keys; Sun keyboards and a few other manufacturers
! have such function key groups on the left and/or right sides of the
! keyboard. We've not found a keyboard with more than 35 function keys
! total.
CONSTANT: XK_F1             0xffbe
CONSTANT: XK_F2             0xffbf
CONSTANT: XK_F3             0xffc0
CONSTANT: XK_F4             0xffc1
CONSTANT: XK_F5             0xffc2
CONSTANT: XK_F6             0xffc3
CONSTANT: XK_F7             0xffc4
CONSTANT: XK_F8             0xffc5
CONSTANT: XK_F9             0xffc6
CONSTANT: XK_F10            0xffc7
CONSTANT: XK_F11            0xffc8
CONSTANT: XK_L1             0xffc8
CONSTANT: XK_F12            0xffc9
CONSTANT: XK_L2             0xffc9
CONSTANT: XK_F13            0xffca
CONSTANT: XK_L3             0xffca
CONSTANT: XK_F14            0xffcb
CONSTANT: XK_L4             0xffcb
CONSTANT: XK_F15            0xffcc
CONSTANT: XK_L5             0xffcc
CONSTANT: XK_F16            0xffcd
CONSTANT: XK_L6             0xffcd
CONSTANT: XK_F17            0xffce
CONSTANT: XK_L7             0xffce
CONSTANT: XK_F18            0xffcf
CONSTANT: XK_L8             0xffcf
CONSTANT: XK_F19            0xffd0
CONSTANT: XK_L9             0xffd0
CONSTANT: XK_F20            0xffd1
CONSTANT: XK_L10            0xffd1
CONSTANT: XK_F21            0xffd2
CONSTANT: XK_R1             0xffd2
CONSTANT: XK_F22            0xffd3
CONSTANT: XK_R2             0xffd3
CONSTANT: XK_F23            0xffd4
CONSTANT: XK_R3             0xffd4
CONSTANT: XK_F24            0xffd5
CONSTANT: XK_R4             0xffd5
CONSTANT: XK_F25            0xffd6
CONSTANT: XK_R5             0xffd6
CONSTANT: XK_F26            0xffd7
CONSTANT: XK_R6             0xffd7
CONSTANT: XK_F27            0xffd8
CONSTANT: XK_R7             0xffd8
CONSTANT: XK_F28            0xffd9
CONSTANT: XK_R8             0xffd9
CONSTANT: XK_F29            0xffda
CONSTANT: XK_R9             0xffda
CONSTANT: XK_F30            0xffdb
CONSTANT: XK_R10            0xffdb
CONSTANT: XK_F31            0xffdc
CONSTANT: XK_R11            0xffdc
CONSTANT: XK_F32            0xffdd
CONSTANT: XK_R12            0xffdd
CONSTANT: XK_F33            0xffde
CONSTANT: XK_R13            0xffde
CONSTANT: XK_F34            0xffdf
CONSTANT: XK_R14            0xffdf
CONSTANT: XK_F35            0xffe0
CONSTANT: XK_R15            0xffe0

CONSTANT: XK_Shift_L        0xffe1  ! Left shift
CONSTANT: XK_Shift_R        0xffe2  ! Right shift
CONSTANT: XK_Control_L      0xffe3  ! Left control
CONSTANT: XK_Control_R      0xffe4  ! Right control
CONSTANT: XK_Caps_Lock      0xffe5  ! Caps lock
CONSTANT: XK_Shift_Lock     0xffe6  ! Shift lock

CONSTANT: XK_Meta_L         0xffe7  ! Left meta
CONSTANT: XK_Meta_R         0xffe8  ! Right meta
CONSTANT: XK_Alt_L          0xffe9  ! Left alt
CONSTANT: XK_Alt_R          0xffea  ! Right alt
CONSTANT: XK_Super_L        0xffeb  ! Left super
CONSTANT: XK_Super_R        0xffec  ! Right super
CONSTANT: XK_Hyper_L        0xffed  ! Left hyper
CONSTANT: XK_Hyper_R        0xffee  ! Right hyper

! Keyboard (XKB) Extension function and modifier keys (from Appendix C
! of "The X Keyboard Extension: Protocol Specification")
! Byte 3 = 0xfe
CONSTANT: XK_ISO_Lock                      0xfe01
CONSTANT: XK_ISO_Level2_Latch              0xfe02
CONSTANT: XK_ISO_Level3_Shift              0xfe03
CONSTANT: XK_ISO_Level3_Latch              0xfe04
CONSTANT: XK_ISO_Level3_Lock               0xfe05
CONSTANT: XK_ISO_Level5_Shift              0xfe11
CONSTANT: XK_ISO_Level5_Latch              0xfe12
CONSTANT: XK_ISO_Level5_Lock               0xfe13
CONSTANT: XK_ISO_Group_Shift               0xff7e  ! Alias for mode_switch
CONSTANT: XK_ISO_Group_Latch               0xfe06
CONSTANT: XK_ISO_Group_Lock                0xfe07
CONSTANT: XK_ISO_Next_Group                0xfe08
CONSTANT: XK_ISO_Next_Group_Lock           0xfe09
CONSTANT: XK_ISO_Prev_Group                0xfe0a
CONSTANT: XK_ISO_Prev_Group_Lock           0xfe0b
CONSTANT: XK_ISO_First_Group               0xfe0c
CONSTANT: XK_ISO_First_Group_Lock          0xfe0d
CONSTANT: XK_ISO_Last_Group                0xfe0e
CONSTANT: XK_ISO_Last_Group_Lock           0xfe0f

CONSTANT: XK_ISO_Left_Tab                  0xfe20
CONSTANT: XK_ISO_Move_Line_Up              0xfe21
CONSTANT: XK_ISO_Move_Line_Down            0xfe22
CONSTANT: XK_ISO_Partial_Line_Up           0xfe23
CONSTANT: XK_ISO_Partial_Line_Down         0xfe24
CONSTANT: XK_ISO_Partial_Space_Left        0xfe25
CONSTANT: XK_ISO_Partial_Space_Right       0xfe26
CONSTANT: XK_ISO_Set_Margin_Left           0xfe27
CONSTANT: XK_ISO_Set_Margin_Right          0xfe28
CONSTANT: XK_ISO_Release_Margin_Left       0xfe29
CONSTANT: XK_ISO_Release_Margin_Right      0xfe2a
CONSTANT: XK_ISO_Release_Both_Margins      0xfe2b
CONSTANT: XK_ISO_Fast_Cursor_Left          0xfe2c
CONSTANT: XK_ISO_Fast_Cursor_Right         0xfe2d
CONSTANT: XK_ISO_Fast_Cursor_Up            0xfe2e
CONSTANT: XK_ISO_Fast_Cursor_Down          0xfe2f
CONSTANT: XK_ISO_Continuous_Underline      0xfe30
CONSTANT: XK_ISO_Discontinuous_Underline   0xfe31
CONSTANT: XK_ISO_Emphasize                 0xfe32
CONSTANT: XK_ISO_Center_Object             0xfe33
CONSTANT: XK_ISO_Enter                     0xfe34
