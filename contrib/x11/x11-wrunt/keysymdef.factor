! remarkably similar to parts of keysymdef.h
IN: x11

: XK_BackSpace		HEX: FF08 ; ! back space, back char
: XK_Tab		HEX: FF09 ;
: XK_Linefeed		HEX: FF0A ; ! Linefeed, LF
: XK_Clear		HEX: FF0B ;
: XK_Return		HEX: FF0D ; ! Return, enter
: XK_Pause		HEX: FF13 ; ! Pause, hold
: XK_Scroll_Lock	HEX: FF14 ;
: XK_Sys_Req		HEX: FF15 ;
: XK_Escape		HEX: FF1B ;
: XK_Delete		HEX: FFFF ; ! Delete, rubout

! Cursor control & motion

: XK_Home		HEX: FF50 ;
: XK_Left		HEX: FF51 ; ! Move left, left arrow
: XK_Up			HEX: FF52 ; ! Move up, up arrow
: XK_Right		HEX: FF53 ; ! Move right, right arrow
: XK_Down		HEX: FF54 ; ! Move down, down arrow
: XK_Prior		HEX: FF55 ; ! Prior, previous
: XK_Page_Up		HEX: FF55 ;
: XK_Next		HEX: FF56 ; ! Next
: XK_Page_Down		HEX: FF56 ;
: XK_End		HEX: FF57 ; ! EOL
: XK_Begin		HEX: FF58 ; ! BOL

! Keypad Functions, keypad numbers cleverly chosen to map to ascii

: XK_KP_Space		HEX: FF80 ; ! space
: XK_KP_Tab		HEX: FF89 ;
: XK_KP_Enter		HEX: FF8D ; ! enter
: XK_KP_F1		HEX: FF91 ; ! PF1, KP_A, ...
: XK_KP_F2		HEX: FF92 ;
: XK_KP_F3		HEX: FF93 ;
: XK_KP_F4		HEX: FF94 ;
: XK_KP_Home		HEX: FF95 ;
: XK_KP_Left		HEX: FF96 ;
: XK_KP_Up		HEX: FF97 ;
: XK_KP_Right		HEX: FF98 ;
: XK_KP_Down		HEX: FF99 ;
: XK_KP_Prior		HEX: FF9A ;
: XK_KP_Page_Up		HEX: FF9A ;
: XK_KP_Next		HEX: FF9B ;
: XK_KP_Page_Down	HEX: FF9B ;
: XK_KP_End		HEX: FF9C ;
: XK_KP_Begin		HEX: FF9D ;
: XK_KP_Insert		HEX: FF9E ;
: XK_KP_Delete		HEX: FF9F ;
: XK_KP_Equal		HEX: FFBD ; ! equals
: XK_KP_Multiply	HEX: FFAA ;
: XK_KP_Add		HEX: FFAB ;
: XK_KP_Separator	HEX: FFAC ; ! separator, often comma
: XK_KP_Subtract	HEX: FFAD ;
: XK_KP_Decimal		HEX: FFAE ;
: XK_KP_Divide		HEX: FFAF ;

: XK_KP_0		HEX: FFB0 ;
: XK_KP_1		HEX: FFB1 ;
: XK_KP_2		HEX: FFB2 ;
: XK_KP_3		HEX: FFB3 ;
: XK_KP_4		HEX: FFB4 ;
: XK_KP_5		HEX: FFB5 ;
: XK_KP_6		HEX: FFB6 ;
: XK_KP_7		HEX: FFB7 ;
: XK_KP_8		HEX: FFB8 ;
: XK_KP_9		HEX: FFB9 ;

