USING: windows.dinput windows.kernel32 windows.ole32 windows.com
windows.com.syntax alien alien.c-types alien.syntax kernel system namespaces
combinators sequences fry math accessors macros words quotations
libc continuations generalizations splitting locals assocs init
struct-arrays ;
IN: windows.dinput.constants

! Some global variables aren't provided by the DirectInput DLL (they're in the
! dinput8.lib import library), so we lovingly hand-craft equivalent values here

SYMBOLS:
    GUID_XAxis_malloced GUID_YAxis_malloced GUID_ZAxis_malloced
    GUID_RxAxis_malloced GUID_RyAxis_malloced GUID_RzAxis_malloced
    GUID_Slider_malloced GUID_Button_malloced GUID_Key_malloced GUID_POV_malloced GUID_Unknown_malloced
    GUID_SysMouse_malloced GUID_SysKeyboard_malloced GUID_Joystick_malloced GUID_SysMouseEm_malloced
    GUID_SysMouseEm2_malloced GUID_SysKeyboardEm_malloced GUID_SysKeyboardEm2_malloced
    c_dfDIKeyboard c_dfDIKeyboard_HID c_dfDIMouse2 c_dfDIJoystick2 ;

<PRIVATE

: (field-spec-of) ( field struct -- field-spec )
    c-type fields>> [ name>> = ] with find nip ;
: (offsetof) ( field struct -- offset )
    [ (field-spec-of) offset>> ] [ drop 0 ] if* ;
: (sizeof) ( field struct -- size )
    [ (field-spec-of) type>> "[" split1 drop heap-size ] [ drop 1 ] if* ;

: (flag) ( thing -- integer )
    {
        { [ dup word? ] [ execute ] }
        { [ dup callable? ] [ call ] }
        [ ]
    } cond ;

: (flags) ( array -- )
    0 [ (flag) bitor ] reduce ;

: (DIOBJECTDATAFORMAT) ( pguid dwOfs dwType dwFlags alien -- alien )
    [ {
        [ set-DIOBJECTDATAFORMAT-dwFlags ]
        [ set-DIOBJECTDATAFORMAT-dwType ]
        [ set-DIOBJECTDATAFORMAT-dwOfs ]
        [ set-DIOBJECTDATAFORMAT-pguid ]
    } cleave ] keep ;

: <DIOBJECTDATAFORMAT> ( struct {pguid-var,field,index,dwType-flags,dwFlags} -- alien )
    {
        [ first dup word? [ get ] when ]
        [ second rot [ (offsetof) ] [ (sizeof) ] 2bi ]
        [ third * + ]
        [ fourth (flags) ]
        [ 4 swap nth (flag) ]
    } cleave
    "DIOBJECTDATAFORMAT" <c-object> (DIOBJECTDATAFORMAT) ;

:: malloc-DIOBJECTDATAFORMAT-array ( struct array -- alien )
    [let | alien [ array length "DIOBJECTDATAFORMAT" malloc-struct-array ] |
        array [| args i |
            struct args <DIOBJECTDATAFORMAT>
            i alien set-nth
        ] each-index
        alien
    ] ;

: (DIDATAFORMAT) ( dwSize dwObjSize dwFlags dwDataSize dwNumObjs rgodf alien -- alien )
    [ {
        [ set-DIDATAFORMAT-rgodf ]
        [ set-DIDATAFORMAT-dwNumObjs ]
        [ set-DIDATAFORMAT-dwDataSize ]
        [ set-DIDATAFORMAT-dwFlags ]
        [ set-DIDATAFORMAT-dwObjSize ]
        [ set-DIDATAFORMAT-dwSize ]
    } cleave ] keep ;

: <DIDATAFORMAT> ( dwFlags dwDataSize struct rgodf-array -- alien )
    [ "DIDATAFORMAT" heap-size "DIOBJECTDATAFORMAT" heap-size ] 4 ndip
    [ nip length ] [ malloc-DIOBJECTDATAFORMAT-array ] 2bi
    "DIDATAFORMAT" <c-object> (DIDATAFORMAT) ;

: (malloc-guid-symbol) ( symbol guid -- )
    global swap '[ [
        _ execute [ byte-length malloc ] [ over byte-array>memory ] bi
    ] unless* ] change-at ;

: define-guid-constants ( -- )
    {
        { GUID_XAxis_malloced          GUID_XAxis }
        { GUID_YAxis_malloced          GUID_YAxis }
        { GUID_ZAxis_malloced          GUID_ZAxis }
        { GUID_RxAxis_malloced         GUID_RxAxis }
        { GUID_RyAxis_malloced         GUID_RyAxis }
        { GUID_RzAxis_malloced         GUID_RzAxis }
        { GUID_Slider_malloced         GUID_Slider }
        { GUID_Button_malloced         GUID_Button }
        { GUID_Key_malloced            GUID_Key }
        { GUID_POV_malloced            GUID_POV }
        { GUID_Unknown_malloced        GUID_Unknown }
        { GUID_SysMouse_malloced       GUID_SysMouse }
        { GUID_SysKeyboard_malloced    GUID_SysKeyboard }
        { GUID_Joystick_malloced       GUID_Joystick }
        { GUID_SysMouseEm_malloced     GUID_SysMouseEm }
        { GUID_SysMouseEm2_malloced    GUID_SysMouseEm2 }
        { GUID_SysKeyboardEm_malloced  GUID_SysKeyboardEm }
        { GUID_SysKeyboardEm2_malloced GUID_SysKeyboardEm2 }
    } [ first2 (malloc-guid-symbol) ] each ;

: define-joystick-format-constant ( -- )
    c_dfDIJoystick2 global [ [
        DIDF_ABSAXIS
        "DIJOYSTATE2" heap-size
        "DIJOYSTATE2" {
            { GUID_XAxis_malloced  "lX"           0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_YAxis_malloced  "lY"           0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_ZAxis_malloced  "lZ"           0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_RxAxis_malloced "lRx"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_RyAxis_malloced "lRy"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_RzAxis_malloced "lRz"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_Slider_malloced "rglSlider"    0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_Slider_malloced "rglSlider"    1 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } 0 }
            { GUID_POV_malloced    "rgdwPOV"      0 { DIDFT_OPTIONAL DIDFT_POV    DIDFT_ANYINSTANCE } 0 }
            { GUID_POV_malloced    "rgdwPOV"      1 { DIDFT_OPTIONAL DIDFT_POV    DIDFT_ANYINSTANCE } 0 }
            { GUID_POV_malloced    "rgdwPOV"      2 { DIDFT_OPTIONAL DIDFT_POV    DIDFT_ANYINSTANCE } 0 }
            { GUID_POV_malloced    "rgdwPOV"      3 { DIDFT_OPTIONAL DIDFT_POV    DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   0 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   1 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   2 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   3 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   4 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   5 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   6 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   7 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   8 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"   9 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  10 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  11 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  12 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  13 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  14 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  15 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  16 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  17 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  18 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  19 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  20 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  21 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  22 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  23 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  24 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  25 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  26 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  27 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  28 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  29 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  30 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  31 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  32 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  33 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  34 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  35 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  36 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  37 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  38 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  39 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  40 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  41 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  42 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  43 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  44 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  45 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  46 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  47 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  48 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  49 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  50 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  51 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  52 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  53 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  54 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  55 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  56 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  57 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  58 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  59 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  60 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  61 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  62 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  63 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  64 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  65 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  66 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  67 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  68 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  69 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  70 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  71 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  72 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  73 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  74 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  75 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  76 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  77 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  78 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  79 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  80 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  81 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  82 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  83 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  84 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  85 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  86 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  87 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  88 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  89 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  90 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  91 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  92 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  93 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  94 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  95 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  96 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  97 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  98 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons"  99 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 100 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 101 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 102 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 103 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 104 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 105 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 106 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 107 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 108 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 109 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 110 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 111 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 112 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 113 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 114 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 115 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 116 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 117 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 118 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 119 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 120 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 121 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 122 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 123 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 124 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 125 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 126 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { f           "rgbButtons" 127 { DIDFT_OPTIONAL DIDFT_BUTTON DIDFT_ANYINSTANCE } 0 }
            { GUID_XAxis_malloced  "lVX"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_YAxis_malloced  "lVY"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_ZAxis_malloced  "lVZ"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_RxAxis_malloced "lVRx"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_RyAxis_malloced "lVRy"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_RzAxis_malloced "lVRz"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_Slider_malloced "rglVSlider"   0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_Slider_malloced "rglVSlider"   1 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTVELOCITY }
            { GUID_XAxis_malloced  "lAX"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_YAxis_malloced  "lAY"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_ZAxis_malloced  "lAZ"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_RxAxis_malloced "lARx"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_RyAxis_malloced "lARy"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_RzAxis_malloced "lARz"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_Slider_malloced "rglASlider"   0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_Slider_malloced "rglASlider"   1 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTACCEL }
            { GUID_XAxis_malloced  "lFX"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_YAxis_malloced  "lFY"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_ZAxis_malloced  "lFZ"          0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_RxAxis_malloced "lFRx"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_RyAxis_malloced "lFRy"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_RzAxis_malloced "lFRz"         0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_Slider_malloced "rglFSlider"   0 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
            { GUID_Slider_malloced "rglFSlider"   1 { DIDFT_OPTIONAL DIDFT_AXIS   DIDFT_ANYINSTANCE } DIDOI_ASPECTFORCE }
        } <DIDATAFORMAT>
    ] unless* ] change-at ;

: define-mouse-format-constant ( -- )
    c_dfDIMouse2 global [ [
        DIDF_RELAXIS
        "DIMOUSESTATE2" heap-size
        "DIMOUSESTATE2" {
            { GUID_XAxis_malloced  "lX"         0 {                DIDFT_ANYINSTANCE DIDFT_AXIS   } 0 }
            { GUID_YAxis_malloced  "lY"         0 {                DIDFT_ANYINSTANCE DIDFT_AXIS   } 0 }
            { GUID_ZAxis_malloced  "lZ"         0 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_AXIS   } 0 }
            { GUID_Button_malloced "rgbButtons" 0 {                DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 1 {                DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 2 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 3 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 4 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 5 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 6 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
            { GUID_Button_malloced "rgbButtons" 7 { DIDFT_OPTIONAL DIDFT_ANYINSTANCE DIDFT_BUTTON } 0 }
        } <DIDATAFORMAT>
    ] unless* ] change-at ;

! Not a standard DirectInput format. Included for cross-platform niceness.
! This format returns the keyboard keys in USB HID order rather than Windows
! order
: define-hid-keyboard-format-constant ( -- )
    c_dfDIKeyboard_HID global [ [
        DIDF_RELAXIS
        256
        f {
            { GUID_Key_malloced f   0 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   1 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   2 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   3 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   4 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_A DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   5 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_B DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   6 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_C DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   7 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_D DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   8 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_E DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   9 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  10 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_G DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  11 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_H DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  12 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_I DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  13 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_J DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  14 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_K DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  15 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_L DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  16 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_M DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  17 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_N DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  18 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_O DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  19 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_P DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  20 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_Q DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  21 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_R DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  22 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_S DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  23 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_T DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  24 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_U DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  25 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_V DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  26 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_W DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  27 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_X DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  28 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_Y DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  29 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_Z DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  30 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_1 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  31 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_2 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  32 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_3 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  33 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_4 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  34 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_5 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  35 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_6 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  36 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_7 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  37 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_8 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  38 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_9 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  39 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  40 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RETURN DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  41 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_ESCAPE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  42 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_BACK DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  43 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_TAB DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  44 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_SPACE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  45 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_MINUS DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  46 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_EQUALS DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  47 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_LBRACKET DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  48 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RBRACKET DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  49 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_BACKSLASH DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  50 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  51 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_SEMICOLON DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  52 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_APOSTROPHE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  53 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_GRAVE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  54 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_COMMA  DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  55 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_PERIOD DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  56 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_SLASH  DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  57 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_CAPITAL DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  58 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F1 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  59 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F2 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  60 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F3 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  61 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F4 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  62 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F5 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  63 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F6 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  64 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F7 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  65 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F8 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  66 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F9 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  67 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F10 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  68 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F11 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  69 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F12 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  70 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_SYSRQ DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  71 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_SCROLL DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  72 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_PAUSE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  73 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_INSERT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  74 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_HOME DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  75 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_PRIOR DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  76 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_DELETE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  77 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_END DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  78 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NEXT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  79 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RIGHT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  80 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_LEFT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  81 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_DOWN DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  82 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_UP DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  83 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMLOCK DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  84 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_DIVIDE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  85 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_MULTIPLY DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  86 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_SUBTRACT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  87 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_ADD DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  88 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPADENTER DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  89 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD1 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  90 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD2 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  91 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD3 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  92 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD4 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  93 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD5 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  94 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD6 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  95 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD7 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  96 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD8 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  97 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD9 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  98 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPAD0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  99 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_DECIMAL DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 100 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_OEM_102 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 101 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_APPS DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 102 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_POWER DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 103 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NUMPADEQUALS DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 104 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F13 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 105 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F14 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 106 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_F15 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 107 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 108 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 109 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 110 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 111 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 112 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 113 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 114 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 115 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 116 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 117 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 118 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 119 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 120 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 121 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 122 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 123 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 124 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 125 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 126 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 127 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_MUTE DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 128 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_VOLUMEUP DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 129 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_VOLUMEDOWN DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 130 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 131 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 132 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 133 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_ABNT_C2 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 134 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 135 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_ABNT_C1 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 136 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_KANA DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 137 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_YEN DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 138 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_CONVERT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 139 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_NOCONVERT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 140 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 141 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 142 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 143 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 144 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 145 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 146 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 147 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 148 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 149 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 150 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 151 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 152 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 153 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 154 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 155 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 156 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 157 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 158 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 159 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 160 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 161 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 162 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 163 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 164 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 165 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 166 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 167 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 168 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 169 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 170 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 171 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 172 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 173 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 174 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 175 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 176 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 177 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 178 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 179 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 180 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 181 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 182 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 183 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 184 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 185 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 186 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 187 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 188 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 189 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 190 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 191 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 192 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 193 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 194 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 195 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 196 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 197 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 198 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 199 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 200 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 201 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 202 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 203 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 204 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 205 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 206 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 207 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 208 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 209 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 210 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 211 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 212 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 213 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 214 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 215 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 216 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 217 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 218 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 219 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 220 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 221 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 222 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 223 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 224 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_LCONTROL DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 225 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_LSHIFT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 226 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_LMENU DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 227 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_LWIN DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 228 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RCONTROL DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 229 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RSHIFT DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 230 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RMENU DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 231 { DIDFT_OPTIONAL DIDFT_BUTTON [ DIK_RWIN DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 232 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 233 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 234 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 235 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 236 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 237 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 238 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 239 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 240 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 241 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 242 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 243 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 244 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 245 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 246 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 247 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 248 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 249 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 250 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 251 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 252 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 253 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 254 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 255 { DIDFT_OPTIONAL DIDFT_BUTTON [ 0 DIDFT_MAKEINSTANCE ] } 0 }
        } <DIDATAFORMAT>
    ] unless* ] change-at ;

: define-keyboard-format-constant ( -- )
    c_dfDIKeyboard global [ [
        DIDF_RELAXIS
        256
        f {
            { GUID_Key_malloced f   0 { DIDFT_OPTIONAL DIDFT_BUTTON [   0 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   1 { DIDFT_OPTIONAL DIDFT_BUTTON [   1 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   2 { DIDFT_OPTIONAL DIDFT_BUTTON [   2 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   3 { DIDFT_OPTIONAL DIDFT_BUTTON [   3 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   4 { DIDFT_OPTIONAL DIDFT_BUTTON [   4 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   5 { DIDFT_OPTIONAL DIDFT_BUTTON [   5 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   6 { DIDFT_OPTIONAL DIDFT_BUTTON [   6 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   7 { DIDFT_OPTIONAL DIDFT_BUTTON [   7 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   8 { DIDFT_OPTIONAL DIDFT_BUTTON [   8 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f   9 { DIDFT_OPTIONAL DIDFT_BUTTON [   9 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  10 { DIDFT_OPTIONAL DIDFT_BUTTON [  10 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  11 { DIDFT_OPTIONAL DIDFT_BUTTON [  11 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  12 { DIDFT_OPTIONAL DIDFT_BUTTON [  12 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  13 { DIDFT_OPTIONAL DIDFT_BUTTON [  13 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  14 { DIDFT_OPTIONAL DIDFT_BUTTON [  14 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  15 { DIDFT_OPTIONAL DIDFT_BUTTON [  15 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  16 { DIDFT_OPTIONAL DIDFT_BUTTON [  16 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  17 { DIDFT_OPTIONAL DIDFT_BUTTON [  17 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  18 { DIDFT_OPTIONAL DIDFT_BUTTON [  18 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  19 { DIDFT_OPTIONAL DIDFT_BUTTON [  19 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  20 { DIDFT_OPTIONAL DIDFT_BUTTON [  20 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  21 { DIDFT_OPTIONAL DIDFT_BUTTON [  21 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  22 { DIDFT_OPTIONAL DIDFT_BUTTON [  22 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  23 { DIDFT_OPTIONAL DIDFT_BUTTON [  23 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  24 { DIDFT_OPTIONAL DIDFT_BUTTON [  24 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  25 { DIDFT_OPTIONAL DIDFT_BUTTON [  25 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  26 { DIDFT_OPTIONAL DIDFT_BUTTON [  26 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  27 { DIDFT_OPTIONAL DIDFT_BUTTON [  27 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  28 { DIDFT_OPTIONAL DIDFT_BUTTON [  28 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  29 { DIDFT_OPTIONAL DIDFT_BUTTON [  29 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  30 { DIDFT_OPTIONAL DIDFT_BUTTON [  30 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  31 { DIDFT_OPTIONAL DIDFT_BUTTON [  31 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  32 { DIDFT_OPTIONAL DIDFT_BUTTON [  32 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  33 { DIDFT_OPTIONAL DIDFT_BUTTON [  33 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  34 { DIDFT_OPTIONAL DIDFT_BUTTON [  34 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  35 { DIDFT_OPTIONAL DIDFT_BUTTON [  35 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  36 { DIDFT_OPTIONAL DIDFT_BUTTON [  36 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  37 { DIDFT_OPTIONAL DIDFT_BUTTON [  37 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  38 { DIDFT_OPTIONAL DIDFT_BUTTON [  38 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  39 { DIDFT_OPTIONAL DIDFT_BUTTON [  39 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  40 { DIDFT_OPTIONAL DIDFT_BUTTON [  40 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  41 { DIDFT_OPTIONAL DIDFT_BUTTON [  41 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  42 { DIDFT_OPTIONAL DIDFT_BUTTON [  42 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  43 { DIDFT_OPTIONAL DIDFT_BUTTON [  43 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  44 { DIDFT_OPTIONAL DIDFT_BUTTON [  44 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  45 { DIDFT_OPTIONAL DIDFT_BUTTON [  45 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  46 { DIDFT_OPTIONAL DIDFT_BUTTON [  46 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  47 { DIDFT_OPTIONAL DIDFT_BUTTON [  47 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  48 { DIDFT_OPTIONAL DIDFT_BUTTON [  48 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  49 { DIDFT_OPTIONAL DIDFT_BUTTON [  49 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  50 { DIDFT_OPTIONAL DIDFT_BUTTON [  50 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  51 { DIDFT_OPTIONAL DIDFT_BUTTON [  51 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  52 { DIDFT_OPTIONAL DIDFT_BUTTON [  52 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  53 { DIDFT_OPTIONAL DIDFT_BUTTON [  53 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  54 { DIDFT_OPTIONAL DIDFT_BUTTON [  54 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  55 { DIDFT_OPTIONAL DIDFT_BUTTON [  55 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  56 { DIDFT_OPTIONAL DIDFT_BUTTON [  56 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  57 { DIDFT_OPTIONAL DIDFT_BUTTON [  57 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  58 { DIDFT_OPTIONAL DIDFT_BUTTON [  58 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  59 { DIDFT_OPTIONAL DIDFT_BUTTON [  59 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  60 { DIDFT_OPTIONAL DIDFT_BUTTON [  60 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  61 { DIDFT_OPTIONAL DIDFT_BUTTON [  61 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  62 { DIDFT_OPTIONAL DIDFT_BUTTON [  62 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  63 { DIDFT_OPTIONAL DIDFT_BUTTON [  63 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  64 { DIDFT_OPTIONAL DIDFT_BUTTON [  64 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  65 { DIDFT_OPTIONAL DIDFT_BUTTON [  65 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  66 { DIDFT_OPTIONAL DIDFT_BUTTON [  66 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  67 { DIDFT_OPTIONAL DIDFT_BUTTON [  67 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  68 { DIDFT_OPTIONAL DIDFT_BUTTON [  68 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  69 { DIDFT_OPTIONAL DIDFT_BUTTON [  69 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  70 { DIDFT_OPTIONAL DIDFT_BUTTON [  70 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  71 { DIDFT_OPTIONAL DIDFT_BUTTON [  71 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  72 { DIDFT_OPTIONAL DIDFT_BUTTON [  72 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  73 { DIDFT_OPTIONAL DIDFT_BUTTON [  73 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  74 { DIDFT_OPTIONAL DIDFT_BUTTON [  74 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  75 { DIDFT_OPTIONAL DIDFT_BUTTON [  75 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  76 { DIDFT_OPTIONAL DIDFT_BUTTON [  76 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  77 { DIDFT_OPTIONAL DIDFT_BUTTON [  77 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  78 { DIDFT_OPTIONAL DIDFT_BUTTON [  78 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  79 { DIDFT_OPTIONAL DIDFT_BUTTON [  79 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  80 { DIDFT_OPTIONAL DIDFT_BUTTON [  80 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  81 { DIDFT_OPTIONAL DIDFT_BUTTON [  81 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  82 { DIDFT_OPTIONAL DIDFT_BUTTON [  82 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  83 { DIDFT_OPTIONAL DIDFT_BUTTON [  83 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  84 { DIDFT_OPTIONAL DIDFT_BUTTON [  84 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  85 { DIDFT_OPTIONAL DIDFT_BUTTON [  85 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  86 { DIDFT_OPTIONAL DIDFT_BUTTON [  86 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  87 { DIDFT_OPTIONAL DIDFT_BUTTON [  87 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  88 { DIDFT_OPTIONAL DIDFT_BUTTON [  88 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  89 { DIDFT_OPTIONAL DIDFT_BUTTON [  89 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  90 { DIDFT_OPTIONAL DIDFT_BUTTON [  90 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  91 { DIDFT_OPTIONAL DIDFT_BUTTON [  91 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  92 { DIDFT_OPTIONAL DIDFT_BUTTON [  92 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  93 { DIDFT_OPTIONAL DIDFT_BUTTON [  93 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  94 { DIDFT_OPTIONAL DIDFT_BUTTON [  94 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  95 { DIDFT_OPTIONAL DIDFT_BUTTON [  95 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  96 { DIDFT_OPTIONAL DIDFT_BUTTON [  96 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  97 { DIDFT_OPTIONAL DIDFT_BUTTON [  97 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  98 { DIDFT_OPTIONAL DIDFT_BUTTON [  98 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f  99 { DIDFT_OPTIONAL DIDFT_BUTTON [  99 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 100 { DIDFT_OPTIONAL DIDFT_BUTTON [ 100 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 101 { DIDFT_OPTIONAL DIDFT_BUTTON [ 101 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 102 { DIDFT_OPTIONAL DIDFT_BUTTON [ 102 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 103 { DIDFT_OPTIONAL DIDFT_BUTTON [ 103 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 104 { DIDFT_OPTIONAL DIDFT_BUTTON [ 104 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 105 { DIDFT_OPTIONAL DIDFT_BUTTON [ 105 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 106 { DIDFT_OPTIONAL DIDFT_BUTTON [ 106 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 107 { DIDFT_OPTIONAL DIDFT_BUTTON [ 107 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 108 { DIDFT_OPTIONAL DIDFT_BUTTON [ 108 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 109 { DIDFT_OPTIONAL DIDFT_BUTTON [ 109 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 110 { DIDFT_OPTIONAL DIDFT_BUTTON [ 110 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 111 { DIDFT_OPTIONAL DIDFT_BUTTON [ 111 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 112 { DIDFT_OPTIONAL DIDFT_BUTTON [ 112 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 113 { DIDFT_OPTIONAL DIDFT_BUTTON [ 113 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 114 { DIDFT_OPTIONAL DIDFT_BUTTON [ 114 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 115 { DIDFT_OPTIONAL DIDFT_BUTTON [ 115 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 116 { DIDFT_OPTIONAL DIDFT_BUTTON [ 116 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 117 { DIDFT_OPTIONAL DIDFT_BUTTON [ 117 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 118 { DIDFT_OPTIONAL DIDFT_BUTTON [ 118 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 119 { DIDFT_OPTIONAL DIDFT_BUTTON [ 119 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 120 { DIDFT_OPTIONAL DIDFT_BUTTON [ 120 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 121 { DIDFT_OPTIONAL DIDFT_BUTTON [ 121 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 122 { DIDFT_OPTIONAL DIDFT_BUTTON [ 122 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 123 { DIDFT_OPTIONAL DIDFT_BUTTON [ 123 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 124 { DIDFT_OPTIONAL DIDFT_BUTTON [ 124 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 125 { DIDFT_OPTIONAL DIDFT_BUTTON [ 125 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 126 { DIDFT_OPTIONAL DIDFT_BUTTON [ 126 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 127 { DIDFT_OPTIONAL DIDFT_BUTTON [ 127 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 128 { DIDFT_OPTIONAL DIDFT_BUTTON [ 128 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 129 { DIDFT_OPTIONAL DIDFT_BUTTON [ 129 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 130 { DIDFT_OPTIONAL DIDFT_BUTTON [ 130 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 131 { DIDFT_OPTIONAL DIDFT_BUTTON [ 131 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 132 { DIDFT_OPTIONAL DIDFT_BUTTON [ 132 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 133 { DIDFT_OPTIONAL DIDFT_BUTTON [ 133 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 134 { DIDFT_OPTIONAL DIDFT_BUTTON [ 134 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 135 { DIDFT_OPTIONAL DIDFT_BUTTON [ 135 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 136 { DIDFT_OPTIONAL DIDFT_BUTTON [ 136 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 137 { DIDFT_OPTIONAL DIDFT_BUTTON [ 137 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 138 { DIDFT_OPTIONAL DIDFT_BUTTON [ 138 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 139 { DIDFT_OPTIONAL DIDFT_BUTTON [ 139 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 140 { DIDFT_OPTIONAL DIDFT_BUTTON [ 140 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 141 { DIDFT_OPTIONAL DIDFT_BUTTON [ 141 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 142 { DIDFT_OPTIONAL DIDFT_BUTTON [ 142 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 143 { DIDFT_OPTIONAL DIDFT_BUTTON [ 143 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 144 { DIDFT_OPTIONAL DIDFT_BUTTON [ 144 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 145 { DIDFT_OPTIONAL DIDFT_BUTTON [ 145 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 146 { DIDFT_OPTIONAL DIDFT_BUTTON [ 146 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 147 { DIDFT_OPTIONAL DIDFT_BUTTON [ 147 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 148 { DIDFT_OPTIONAL DIDFT_BUTTON [ 148 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 149 { DIDFT_OPTIONAL DIDFT_BUTTON [ 149 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 150 { DIDFT_OPTIONAL DIDFT_BUTTON [ 150 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 151 { DIDFT_OPTIONAL DIDFT_BUTTON [ 151 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 152 { DIDFT_OPTIONAL DIDFT_BUTTON [ 152 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 153 { DIDFT_OPTIONAL DIDFT_BUTTON [ 153 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 154 { DIDFT_OPTIONAL DIDFT_BUTTON [ 154 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 155 { DIDFT_OPTIONAL DIDFT_BUTTON [ 155 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 156 { DIDFT_OPTIONAL DIDFT_BUTTON [ 156 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 157 { DIDFT_OPTIONAL DIDFT_BUTTON [ 157 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 158 { DIDFT_OPTIONAL DIDFT_BUTTON [ 158 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 159 { DIDFT_OPTIONAL DIDFT_BUTTON [ 159 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 160 { DIDFT_OPTIONAL DIDFT_BUTTON [ 160 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 161 { DIDFT_OPTIONAL DIDFT_BUTTON [ 161 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 162 { DIDFT_OPTIONAL DIDFT_BUTTON [ 162 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 163 { DIDFT_OPTIONAL DIDFT_BUTTON [ 163 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 164 { DIDFT_OPTIONAL DIDFT_BUTTON [ 164 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 165 { DIDFT_OPTIONAL DIDFT_BUTTON [ 165 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 166 { DIDFT_OPTIONAL DIDFT_BUTTON [ 166 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 167 { DIDFT_OPTIONAL DIDFT_BUTTON [ 167 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 168 { DIDFT_OPTIONAL DIDFT_BUTTON [ 168 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 169 { DIDFT_OPTIONAL DIDFT_BUTTON [ 169 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 170 { DIDFT_OPTIONAL DIDFT_BUTTON [ 170 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 171 { DIDFT_OPTIONAL DIDFT_BUTTON [ 171 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 172 { DIDFT_OPTIONAL DIDFT_BUTTON [ 172 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 173 { DIDFT_OPTIONAL DIDFT_BUTTON [ 173 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 174 { DIDFT_OPTIONAL DIDFT_BUTTON [ 174 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 175 { DIDFT_OPTIONAL DIDFT_BUTTON [ 175 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 176 { DIDFT_OPTIONAL DIDFT_BUTTON [ 176 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 177 { DIDFT_OPTIONAL DIDFT_BUTTON [ 177 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 178 { DIDFT_OPTIONAL DIDFT_BUTTON [ 178 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 179 { DIDFT_OPTIONAL DIDFT_BUTTON [ 179 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 180 { DIDFT_OPTIONAL DIDFT_BUTTON [ 180 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 181 { DIDFT_OPTIONAL DIDFT_BUTTON [ 181 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 182 { DIDFT_OPTIONAL DIDFT_BUTTON [ 182 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 183 { DIDFT_OPTIONAL DIDFT_BUTTON [ 183 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 184 { DIDFT_OPTIONAL DIDFT_BUTTON [ 184 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 185 { DIDFT_OPTIONAL DIDFT_BUTTON [ 185 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 186 { DIDFT_OPTIONAL DIDFT_BUTTON [ 186 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 187 { DIDFT_OPTIONAL DIDFT_BUTTON [ 187 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 188 { DIDFT_OPTIONAL DIDFT_BUTTON [ 188 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 189 { DIDFT_OPTIONAL DIDFT_BUTTON [ 189 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 190 { DIDFT_OPTIONAL DIDFT_BUTTON [ 190 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 191 { DIDFT_OPTIONAL DIDFT_BUTTON [ 191 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 192 { DIDFT_OPTIONAL DIDFT_BUTTON [ 192 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 193 { DIDFT_OPTIONAL DIDFT_BUTTON [ 193 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 194 { DIDFT_OPTIONAL DIDFT_BUTTON [ 194 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 195 { DIDFT_OPTIONAL DIDFT_BUTTON [ 195 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 196 { DIDFT_OPTIONAL DIDFT_BUTTON [ 196 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 197 { DIDFT_OPTIONAL DIDFT_BUTTON [ 197 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 198 { DIDFT_OPTIONAL DIDFT_BUTTON [ 198 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 199 { DIDFT_OPTIONAL DIDFT_BUTTON [ 199 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 200 { DIDFT_OPTIONAL DIDFT_BUTTON [ 200 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 201 { DIDFT_OPTIONAL DIDFT_BUTTON [ 201 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 202 { DIDFT_OPTIONAL DIDFT_BUTTON [ 202 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 203 { DIDFT_OPTIONAL DIDFT_BUTTON [ 203 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 204 { DIDFT_OPTIONAL DIDFT_BUTTON [ 204 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 205 { DIDFT_OPTIONAL DIDFT_BUTTON [ 205 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 206 { DIDFT_OPTIONAL DIDFT_BUTTON [ 206 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 207 { DIDFT_OPTIONAL DIDFT_BUTTON [ 207 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 208 { DIDFT_OPTIONAL DIDFT_BUTTON [ 208 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 209 { DIDFT_OPTIONAL DIDFT_BUTTON [ 209 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 210 { DIDFT_OPTIONAL DIDFT_BUTTON [ 210 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 211 { DIDFT_OPTIONAL DIDFT_BUTTON [ 211 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 212 { DIDFT_OPTIONAL DIDFT_BUTTON [ 212 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 213 { DIDFT_OPTIONAL DIDFT_BUTTON [ 213 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 214 { DIDFT_OPTIONAL DIDFT_BUTTON [ 214 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 215 { DIDFT_OPTIONAL DIDFT_BUTTON [ 215 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 216 { DIDFT_OPTIONAL DIDFT_BUTTON [ 216 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 217 { DIDFT_OPTIONAL DIDFT_BUTTON [ 217 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 218 { DIDFT_OPTIONAL DIDFT_BUTTON [ 218 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 219 { DIDFT_OPTIONAL DIDFT_BUTTON [ 219 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 220 { DIDFT_OPTIONAL DIDFT_BUTTON [ 220 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 221 { DIDFT_OPTIONAL DIDFT_BUTTON [ 221 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 222 { DIDFT_OPTIONAL DIDFT_BUTTON [ 222 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 223 { DIDFT_OPTIONAL DIDFT_BUTTON [ 223 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 224 { DIDFT_OPTIONAL DIDFT_BUTTON [ 224 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 225 { DIDFT_OPTIONAL DIDFT_BUTTON [ 225 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 226 { DIDFT_OPTIONAL DIDFT_BUTTON [ 226 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 227 { DIDFT_OPTIONAL DIDFT_BUTTON [ 227 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 228 { DIDFT_OPTIONAL DIDFT_BUTTON [ 228 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 229 { DIDFT_OPTIONAL DIDFT_BUTTON [ 229 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 230 { DIDFT_OPTIONAL DIDFT_BUTTON [ 230 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 231 { DIDFT_OPTIONAL DIDFT_BUTTON [ 231 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 232 { DIDFT_OPTIONAL DIDFT_BUTTON [ 232 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 233 { DIDFT_OPTIONAL DIDFT_BUTTON [ 233 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 234 { DIDFT_OPTIONAL DIDFT_BUTTON [ 234 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 235 { DIDFT_OPTIONAL DIDFT_BUTTON [ 235 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 236 { DIDFT_OPTIONAL DIDFT_BUTTON [ 236 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 237 { DIDFT_OPTIONAL DIDFT_BUTTON [ 237 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 238 { DIDFT_OPTIONAL DIDFT_BUTTON [ 238 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 239 { DIDFT_OPTIONAL DIDFT_BUTTON [ 239 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 240 { DIDFT_OPTIONAL DIDFT_BUTTON [ 240 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 241 { DIDFT_OPTIONAL DIDFT_BUTTON [ 241 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 242 { DIDFT_OPTIONAL DIDFT_BUTTON [ 242 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 243 { DIDFT_OPTIONAL DIDFT_BUTTON [ 243 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 244 { DIDFT_OPTIONAL DIDFT_BUTTON [ 244 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 245 { DIDFT_OPTIONAL DIDFT_BUTTON [ 245 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 246 { DIDFT_OPTIONAL DIDFT_BUTTON [ 246 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 247 { DIDFT_OPTIONAL DIDFT_BUTTON [ 247 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 248 { DIDFT_OPTIONAL DIDFT_BUTTON [ 248 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 249 { DIDFT_OPTIONAL DIDFT_BUTTON [ 249 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 250 { DIDFT_OPTIONAL DIDFT_BUTTON [ 250 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 251 { DIDFT_OPTIONAL DIDFT_BUTTON [ 251 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 252 { DIDFT_OPTIONAL DIDFT_BUTTON [ 252 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 253 { DIDFT_OPTIONAL DIDFT_BUTTON [ 253 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 254 { DIDFT_OPTIONAL DIDFT_BUTTON [ 254 DIDFT_MAKEINSTANCE ] } 0 }
            { GUID_Key_malloced f 255 { DIDFT_OPTIONAL DIDFT_BUTTON [ 255 DIDFT_MAKEINSTANCE ] } 0 }
        } <DIDATAFORMAT>
    ] unless* ] change-at ;

: define-format-constants ( -- )
    define-joystick-format-constant
    define-mouse-format-constant
    define-keyboard-format-constant
    define-hid-keyboard-format-constant ;

: define-constants ( -- )
    define-guid-constants
    define-format-constants ;

[ define-constants ] "windows.dinput.constants" add-init-hook
define-constants

: free-dinput-constants ( -- )
    {
        GUID_XAxis_malloced GUID_YAxis_malloced GUID_ZAxis_malloced
        GUID_RxAxis_malloced GUID_RyAxis_malloced GUID_RzAxis_malloced
        GUID_Slider_malloced GUID_Button_malloced GUID_Key_malloced GUID_POV_malloced GUID_Unknown_malloced
        GUID_SysMouse_malloced GUID_SysKeyboard_malloced GUID_Joystick_malloced GUID_SysMouseEm_malloced
        GUID_SysMouseEm2_malloced GUID_SysKeyboardEm_malloced GUID_SysKeyboardEm2_malloced
    } [ global [ [ free ] when* f ] change-at ] each
    {
        c_dfDIKeyboard c_dfDIKeyboard_HID c_dfDIMouse2 c_dfDIJoystick2
    } [ global [ [ DIDATAFORMAT-rgodf free ] when* f ] change-at ] each ;

PRIVATE>

