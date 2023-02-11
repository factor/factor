! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.data alien.syntax byte-arrays
classes.struct combinators continuations io.encodings.string
io.encodings.utf8 kernel libc math math.vectors sequences
splitting unix.ffi unix.types ;
IN: linux.input-events.ffi

! IOCTLs 0x00-0x7f
STRUCT: input_id
    { bustype __u16 }
    { vendor __u16 }
    { product __u16 }
    { version __u16 } ;

STRUCT: input_absinfo
    { value __s32 }
    { minimum __s32 }
    { maximum __s32 }
    { fuzz __s32 }
    { flat __s32 }
    { resolution __s32 } ;

STRUCT: input_keymap_entry
    { flags __u8 }
    { len __u8 }
    { index __u16 }
    { keycode __u32 }
    { scancode __u8[32] } ;

STRUCT: input_mask
    { type __u32 }
    { codes_size __u32 }
    { codes_ptr __u64 } ;

STRUCT: ff_replay
    { length __u16 }
    { delay __u16 } ;

STRUCT: ff_trigger
    { button __u16 }
    { interval __u16 } ;

STRUCT: ff_envelope
    { attack_length __u16 }
    { attack_level __u16 }
    { fade_length __u16 }
    { fade_level __u16 } ;

STRUCT: ff_constant_effect
    { level __s16 }
    { envelope ff_envelope } ;

STRUCT: ff_ramp_effect
    { start_level __s16 }
    { end_level __s16 }
    { envelope ff_envelope } ;

STRUCT: ff_condition_effect
    { right_saturation __u16 }
    { left_saturation __u16 }
    { right_coeff __s16 }
    { left_coeff __s16 }
    { deadband __u16 }
    { center __s16 } ;

STRUCT: ff_periodic_effect
    { waveform __u16 }
    { period __u16 }
    { magnitude __s16 }
    { offset __s16 }
    { phase __u16 }
    { envelope ff_envelope }
    { custom_len __u32 }
    { custom_data __s16* } ;

STRUCT: ff_rumble_effect
    { strong_magnitude __u16 }
    { weak_magnitude __u16 } ;

UNION-STRUCT: ff_dummy
    { constant ff_constant_effect }
    { ramp ff_ramp_effect }
    { periodic ff_periodic_effect }
    { condition ff_condition_effect[2] } ! One for each axis
    { rumble ff_rumble_effect } ;

! direction in degrees, 0, 90, 180, 270: 0x0000 down, 0x4000 left, 0x8000 up, 0xc000 right
STRUCT: ff_effect
    { type __u16 }
    { id __s16 }
    { direction __u16 }
    { trigger ff_trigger }
    { replay ff_replay }
    { union ff_dummy } ;

: n>explode-values ( x -- seq )
    [ dup 0 > ]
    [ dup log2 2^ [ bitxor ] keep ] produce nip reverse ; inline

: n>explode-positions ( x -- seq )
    n>explode-values [ log2 ] map ; inline

: seq>explode-values ( seq -- seq' )
    [ [ n>explode-values ] dip 8 * v+n ] map-index concat ;

: seq>explode-positions ( seq -- seq' )
    [ [ n>explode-positions ] dip 8 * v+n ] map-index concat ;

: values>implode ( seq -- x ) 0 [ bitor ] reduce ;
: positions>implode ( seq -- x ) 0 [ 2^ bitor ] reduce ;

CONSTANT: IOC_NONE 0
CONSTANT: IOC_WRITE 1
CONSTANT: IOC_READ 2

! IOC is encoded as:
CONSTANT: IOC_NRBITS 8
CONSTANT: IOC_TYPEBITS 8
CONSTANT: IOC_SIZEBITS 14
CONSTANT: IOC_DIRBITS 2

CONSTANT: IOC_NRSHIFT 0
CONSTANT: IOC_TYPESHIFT 8  ! NRSHIFT + NRBITS
CONSTANT: IOC_SIZESHIFT 16 ! TYPESHIFT + TYEPBITS
CONSTANT: IOC_DIRSHIFT 30  ! SIZESHIFT + SIZEBITS

: IOC ( dir type-ch nr c-size -- x )
    {
        [ IOC_DIRSHIFT shift ]
        [ IOC_TYPESHIFT shift ]
        [ IOC_NRSHIFT shift ]
        [ IOC_SIZESHIFT shift ]
    } spread + + + ; inline

: IOR-size ( type-ch nr size -- x )
    [ IOC_READ ] 3dip IOC ; inline

: IOR ( type-ch nr c-type -- x c-type )
    [ IOC_READ ] 3dip [ heap-size IOC ] keep ; inline

: IOW ( type-ch nr struct -- x struct )
    [ IOC_WRITE ] 3dip [ byte-length IOC ] keep ; inline
: IOW-size ( type-ch nr size -- x )
    [ IOC_WRITE ] 3dip IOC ; inline

: call-ioctl ( handle id bytes -- ) ioctl io-error ; inline
: call-ioctl-out ( handle id bytes -- out )
    [ ioctl io-error ] keep ; inline

: <0ref> ( type -- ref ) 0 swap <ref> ; inline
: byte-array-ioctl ( handle id len -- out )
    <byte-array> call-ioctl-out ; inline
: c-array-ioctl ( handle id ctype -- out )
    heap-size <byte-array> call-ioctl-out ; inline
: c-string-ioctl ( handle id ctype -- out )
    c-array-ioctl "\0" split1 drop utf8 decode ;
: ctype-ioctl-out ( handle id ctype -- out )
    [ <0ref> call-ioctl-out ] keep deref ; inline
: ctype-ioctl-inout ( handle id bytes type -- out )
    [ call-ioctl-out ] dip deref ; inline
: struct-ioctl ( handle id struct-class -- out )
    new call-ioctl-out ; inline

! EV IOC G/S - evdev ioctl get/set
! EVIOCGVERSION EVIOCGID EVIOCGREP EVIOCSREP
: evdev-get-version ( handle -- version ) CHAR: E 0x01 int IOR ctype-ioctl-out ;
: evdev-get-id ( handle -- version ) CHAR: E 0x02 input_id IOR struct-ioctl ;
: evdev-get-repeat ( handle -- version ) CHAR: E 0x03 { int 2 } IOR c-array-ioctl ;
: evdev-set-repeat ( handle struct -- version )
    [ CHAR: E 0x03 ] dip IOW call-ioctl-out ;
! EVIOCGKEYCODE EVIOCGKEYCODE_V2 EVIOCSKEYCODE EVIOCSKEYCODE_V2
: evdev-get-keycode ( handle -- int[2] ) CHAR: E 0x04 { int 2 } IOR c-array-ioctl ;
: evdev-get-keycode-v2 ( handle -- input_keymap_entry ) CHAR: E 0x04 input_keymap_entry IOR struct-ioctl ;
: evdev-set-keycode ( handle int[2] -- out ) [ CHAR: E 0x04 ] dip IOW call-ioctl-out ;
: evdev-set-keycode-v2 ( handle input_keymap_entry -- out ) [ CHAR: E 0x04 ] dip IOW call-ioctl-out ;
! EVIOCGNAME EVIOCGPHYS EVIOCGUNIQ EVIOCGPROP
: evdev-get-name ( handle -- name ) CHAR: E 0x06 { char 256 } IOR c-string-ioctl ;
: evdev-get-physical ( handle -- physical ) CHAR: E 0x07 { char 256 } IOR c-string-ioctl ;
: evdev-get-unique ( handle -- unique )
    '[ _ CHAR: E 0x08 { char 512 } IOR c-string-ioctl ] [ drop "" ] recover ;
: evdev-get-prop ( handle -- prop ) CHAR: E 0x09 { char 256 } IOR c-string-ioctl ;
! EVIOCGMTSLOTS, size is encoded by IOR
STRUCT: input_mt_request_layout
    { code __u32 }
    { values __s32* } ; ! values[num_slots]
: evdev-get-mt-slots ( handle size input_mt_request_layout -- prop )
    '[ _ CHAR: E 0x0a _ IOR-size _ call-ioctl-out ] [ drop f ] recover ;
! EVIOCGKEY EVIOCGLED EVIOCGSND EVIOCGSW EVIOCGABS EVIOCSABS
: evdev-get-key ( handle -- bytes ) CHAR: E 0x18 256 IOR-size 256 byte-array-ioctl ;
: evdev-get-led ( handle -- bytes ) CHAR: E 0x19 256 IOR-size 256 byte-array-ioctl ;
: evdev-get-sound ( handle -- bytes ) CHAR: E 0x1a 256 IOR-size 256 byte-array-ioctl ;
: evdev-get-switch ( handle -- bytes ) CHAR: E 0x1b 256 IOR-size 256 byte-array-ioctl ;
: evdev-get-abs ( handle n -- int[6] ) [ CHAR: E ] dip 0x40 + input_absinfo IOR struct-ioctl ;
: evdev-set-abs ( handle input_absinfo -- int[6] ) [ CHAR: E ] dip 0xc0 + input_absinfo IOW struct-ioctl ;
! EVIOCSFF EVIOCRMFF EVIOCGEFFECTS
: evdev-set-force-feedback ( handle ff_effect -- out )
    [ CHAR: E 0x80 ] dip IOW call-ioctl-out ;
: evdev-unset-force-feedback ( handle int -- int )
    [ CHAR: E 0x81 ] dip IOW int ctype-ioctl-inout ;
: evdev-get-simulataneous-effects ( handle -- int )
    CHAR: E 0x84 int IOR ctype-ioctl-out ;
! EVIOCGRAB EVIOCREVOKE
: evdev-grab-device ( handle -- int )
    CHAR: E 0x90 69 int <ref> IOW int ctype-ioctl-inout ;
: evdev-ungrab-device ( handle -- )
    CHAR: E 0x90 4 IOW-size f call-ioctl ;
: evdev-revoke-device ( handle -- )
    CHAR: E 0x91 4 IOW-size f call-ioctl ;
! EVIOCGMASK EVIOCSMASK
: evdev-get-event-mask ( handle -- int )
    CHAR: E 0x92 input_mask IOR struct-ioctl ;
: evdev-set-event-mask ( handle event_mask -- int )
    [ CHAR: E 0x93 ] dip IOW call-ioctl-out ;
! EVIOCSCLOCKID
: evdev-set-clock-id ( handle n -- int )
    [ CHAR: E 0xa0 ] dip int <ref> IOW int ctype-ioctl-inout ;

: evdev-get-bytes ( handle ev len -- bits )
    [
        [ IOC_READ CHAR: E ]
        [ 0x20 + ]
        [ IOC ] tri*
    ] keep byte-array-ioctl ;

ENUM: INPUT_PROP
    { INPUT_PROP_POINTER                 0x00 }   ! needs a pointer
    { INPUT_PROP_DIRECT                  0x01 }   ! direct input devices
    { INPUT_PROP_BUTTONPAD               0x02 }   ! has button(s) under pad
    { INPUT_PROP_SEMI_MT                 0x03 }   ! touch rectangle only
    { INPUT_PROP_TOPBUTTONPAD            0x04 }   ! softbuttons at top of pad
    { INPUT_PROP_POINTING_STICK          0x05 }   ! is a pointing stick
    { INPUT_PROP_ACCELEROMETER           0x06 }   ! has accelerometer
    { INPUT_PROP_MAX                     0x1f }
    { INPUT_PROP_CNT                     0x20 } ; ! (INPUT_PROP_MAX + 1)

! Type, 2nd parameter from /dev/input/event8
ENUM: INPUT_EVENT
    { EV_SYN            0x00 }   ! events
    { EV_KEY            0x01 }   ! keys/buttons
    { EV_REL            0x02 }   ! relative
    { EV_ABS            0x03 }   ! absolute
    { EV_MSC            0x04 }   ! miscellaneous
    { EV_SW             0x05 }   ! switches
    { EV_LED            0x11 }   ! LEDs
    { EV_SND            0x12 }   ! sound
    { EV_REP            0x14 }   ! autorepeat
    { EV_FF             0x15 }   ! force feedback
    { EV_PWR            0x16 }   ! power management
    { EV_FF_STATUS      0x17 }   ! force feedback status
    { EV_MAX            0x1f }   ! maximum
    { EV_CNT            0x20 } ; ! EV_MAX + 1

ENUM: INPUT_SYN
    { SYN_REPORT          0 }
    { SYN_CONFIG          1 }
    { SYN_MT_REPORT       2 }
    { SYN_DROPPED         3 }
    { SYN_MAX          0x0f }
    { SYN_CNT          0x10 } ; ! (SYN_MAX+1)

! code, 3rd param
ENUM: INPUT_KEY
    { KEY_RESERVED                         0 }
    { KEY_ESC                              1 }
    { KEY_1                                2 }
    { KEY_2                                3 }
    { KEY_3                                4 }
    { KEY_4                                5 }
    { KEY_5                                6 }
    { KEY_6                                7 }
    { KEY_7                                8 }
    { KEY_8                                9 }
    { KEY_9                               10 }
    { KEY_0                               11 }
    { KEY_MINUS                           12 }
    { KEY_EQUAL                           13 }
    { KEY_BACKSPACE                       14 }
    { KEY_TAB                             15 }
    { KEY_Q                               16 }
    { KEY_W                               17 }
    { KEY_E                               18 }
    { KEY_R                               19 }
    { KEY_T                               20 }
    { KEY_Y                               21 }
    { KEY_U                               22 }
    { KEY_I                               23 }
    { KEY_O                               24 }
    { KEY_P                               25 }
    { KEY_LEFTBRACE                       26 }
    { KEY_RIGHTBRACE                      27 }
    { KEY_ENTER                           28 }
    { KEY_LEFTCTRL                        29 }
    { KEY_A                               30 }
    { KEY_S                               31 }
    { KEY_D                               32 }
    { KEY_F                               33 }
    { KEY_G                               34 }
    { KEY_H                               35 }
    { KEY_J                               36 }
    { KEY_K                               37 }
    { KEY_L                               38 }
    { KEY_SEMICOLON                       39 }
    { KEY_APOSTROPHE                      40 }
    { KEY_GRAVE                           41 }
    { KEY_LEFTSHIFT                       42 }
    { KEY_BACKSLASH                       43 }
    { KEY_Z                               44 }
    { KEY_X                               45 }
    { KEY_C                               46 }
    { KEY_V                               47 }
    { KEY_B                               48 }
    { KEY_N                               49 }
    { KEY_M                               50 }
    { KEY_COMMA                           51 }
    { KEY_DOT                             52 }
    { KEY_SLASH                           53 }
    { KEY_RIGHTSHIFT                      54 }
    { KEY_KPASTERISK                      55 }
    { KEY_LEFTALT                         56 }
    { KEY_SPACE                           57 }
    { KEY_CAPSLOCK                        58 }
    { KEY_F1                              59 }
    { KEY_F2                              60 }
    { KEY_F3                              61 }
    { KEY_F4                              62 }
    { KEY_F5                              63 }
    { KEY_F6                              64 }
    { KEY_F7                              65 }
    { KEY_F8                              66 }
    { KEY_F9                              67 }
    { KEY_F10                             68 }
    { KEY_NUMLOCK                         69 }
    { KEY_SCROLLLOCK                      70 }
    { KEY_KP7                             71 }
    { KEY_KP8                             72 }
    { KEY_KP9                             73 }
    { KEY_KPMINUS                         74 }
    { KEY_KP4                             75 }
    { KEY_KP5                             76 }
    { KEY_KP6                             77 }
    { KEY_KPPLUS                          78 }
    { KEY_KP1                             79 }
    { KEY_KP2                             80 }
    { KEY_KP3                             81 }
    { KEY_KP0                             82 }
    { KEY_KPDOT                           83 }
    { KEY_ZENKAKUHANKAKU                  85 }
    { KEY_102ND                           86 }
    { KEY_F11                             87 }
    { KEY_F12                             88 }
    { KEY_RO                              89 }
    { KEY_KATAKANA                        90 }
    { KEY_HIRAGANA                        91 }
    { KEY_HENKAN                          92 }
    { KEY_KATAKANAHIRAGANA                93 }
    { KEY_MUHENKAN                        94 }
    { KEY_KPJPCOMMA                       95 }
    { KEY_KPENTER                         96 }
    { KEY_RIGHTCTRL                       97 }
    { KEY_KPSLASH                         98 }
    { KEY_SYSRQ                           99 }
    { KEY_RIGHTALT                       100 }
    { KEY_LINEFEED                       101 }
    { KEY_HOME                           102 }
    { KEY_UP                             103 }
    { KEY_PAGEUP                         104 }
    { KEY_LEFT                           105 }
    { KEY_RIGHT                          106 }
    { KEY_END                            107 }
    { KEY_DOWN                           108 }
    { KEY_PAGEDOWN                       109 }
    { KEY_INSERT                         110 }
    { KEY_DELETE                         111 }
    { KEY_MACRO                          112 }
    { KEY_MUTE                           113 }
    { KEY_VOLUMEDOWN                     114 }
    { KEY_VOLUMEUP                       115 }
    { KEY_POWER                          116 }    ! SC System Power Down
    { KEY_KPEQUAL                        117 }
    { KEY_KPPLUSMINUS                    118 }
    { KEY_PAUSE                          119 }
    { KEY_SCALE                          120 }    ! AL Compiz Scale (Expose)
    { KEY_KPCOMMA                        121 }
    { KEY_HANGEUL                        122 }
    { KEY_HANJA                          123 }
    { KEY_YEN                            124 }
    { KEY_LEFTMETA                       125 }
    { KEY_RIGHTMETA                      126 }
    { KEY_COMPOSE                        127 }
    { KEY_STOP                           128 }    ! AC Stop
    { KEY_AGAIN                          129 }
    { KEY_PROPS                          130 }    ! AC Properties
    { KEY_UNDO                           131 }    ! AC Undo
    { KEY_FRONT                          132 }
    { KEY_COPY                           133 }    ! AC Copy
    { KEY_OPEN                           134 }    ! AC Open
    { KEY_PASTE                          135 }    ! AC Paste
    { KEY_FIND                           136 }    ! AC Search
    { KEY_CUT                            137 }    ! AC Cut
    { KEY_HELP                           138 }    ! AL Integrated Help Center
    { KEY_MENU                           139 }    ! Menu (show menu)
    { KEY_CALC                           140 }    ! AL Calculator
    { KEY_SETUP                          141 }
    { KEY_SLEEP                          142 }    ! SC System Sleep
    { KEY_WAKEUP                         143 }    ! System Wake Up
    { KEY_FILE                           144 }    ! AL Local Machine Browser
    { KEY_SENDFILE                       145 }
    { KEY_DELETEFILE                     146 }
    { KEY_XFER                           147 }
    { KEY_PROG1                          148 }
    { KEY_PROG2                          149 }
    { KEY_WWW                            150 }    ! AL Internet Browser
    { KEY_MSDOS                          151 }
    { KEY_COFFEE                         152 }    ! AL Terminal Lock/Screensaver
    { KEY_ROTATE_DISPLAY                 153 }    ! Display orientation for e.g. tablets
    { KEY_CYCLEWINDOWS                   154 }
    { KEY_MAIL                           155 }
    { KEY_BOOKMARKS                      156 }    ! AC Bookmarks
    { KEY_COMPUTER                       157 }
    { KEY_BACK                           158 }    ! AC Back
    { KEY_FORWARD                        159 }    ! AC Forward
    { KEY_CLOSECD                        160 }
    { KEY_EJECTCD                        161 }
    { KEY_EJECTCLOSECD                   162 }
    { KEY_NEXTSONG                       163 }
    { KEY_PLAYPAUSE                      164 }
    { KEY_PREVIOUSSONG                   165 }
    { KEY_STOPCD                         166 }
    { KEY_RECORD                         167 }
    { KEY_REWIND                         168 }
    { KEY_PHONE                          169 }    ! Media Select Telephone
    { KEY_ISO                            170 }
    { KEY_CONFIG                         171 }    ! AL Consumer Control Configuration
    { KEY_HOMEPAGE                       172 }    ! AC Home
    { KEY_REFRESH                        173 }    ! AC Refresh
    { KEY_EXIT                           174 }    ! AC Exit
    { KEY_MOVE                           175 }
    { KEY_EDIT                           176 }
    { KEY_SCROLLUP                       177 }
    { KEY_SCROLLDOWN                     178 }
    { KEY_KPLEFTPAREN                    179 }
    { KEY_KPRIGHTPAREN                   180 }
    { KEY_NEW                            181 }    ! AC New
    { KEY_REDO                           182 }    ! AC Redo/Repeat
    { KEY_F13                            183 }
    { KEY_F14                            184 }
    { KEY_F15                            185 }
    { KEY_F16                            186 }
    { KEY_F17                            187 }
    { KEY_F18                            188 }
    { KEY_F19                            189 }
    { KEY_F20                            190 }
    { KEY_F21                            191 }
    { KEY_F22                            192 }
    { KEY_F23                            193 }
    { KEY_F24                            194 }
    { KEY_PLAYCD                         200 }
    { KEY_PAUSECD                        201 }
    { KEY_PROG3                          202 }
    { KEY_PROG4                          203 }
    { KEY_DASHBOARD                      204 }    ! AL Dashboard
    { KEY_SUSPEND                        205 }
    { KEY_CLOSE                          206 }    ! AC Close
    { KEY_PLAY                           207 }
    { KEY_FASTFORWARD                    208 }
    { KEY_BASSBOOST                      209 }
    { KEY_PRINT                          210 }    ! AC Print
    { KEY_HP                             211 }
    { KEY_CAMERA                         212 }
    { KEY_SOUND                          213 }
    { KEY_QUESTION                       214 }
    { KEY_EMAIL                          215 }
    { KEY_CHAT                           216 }
    { KEY_SEARCH                         217 }
    { KEY_CONNECT                        218 }
    { KEY_FINANCE                        219 }    ! AL Checkbook/Finance
    { KEY_SPORT                          220 }
    { KEY_SHOP                           221 }
    { KEY_ALTERASE                       222 }
    { KEY_CANCEL                         223 }    ! AC Cancel
    { KEY_BRIGHTNESSDOWN                 224 }
    { KEY_BRIGHTNESSUP                   225 }
    { KEY_MEDIA                          226 }
    { KEY_SWITCHVIDEOMODE                227 }    ! Cycle between available video
                                                  ! outputs (Monitor/LCD/TV-out/etc)
    { KEY_KBDILLUMTOGGLE                 228 }
    { KEY_KBDILLUMDOWN                   229 }
    { KEY_KBDILLUMUP                     230 }
    { KEY_SEND                           231 }    ! AC Send
    { KEY_REPLY                          232 }    ! AC Reply
    { KEY_FORWARDMAIL                    233 }    ! AC Forward Msg
    { KEY_SAVE                           234 }    ! AC Save
    { KEY_DOCUMENTS                      235 }
    { KEY_BATTERY                        236 }
    { KEY_BLUETOOTH                      237 }
    { KEY_WLAN                           238 }
    { KEY_UWB                            239 }
    { KEY_UNKNOWN                        240 }
    { KEY_VIDEO_NEXT                     241 }    ! drive next video source
    { KEY_VIDEO_PREV                     242 }    ! drive previous video source
    { KEY_BRIGHTNESS_CYCLE               243 }    ! brightness up, after max is min
    { KEY_BRIGHTNESS_AUTO                244 }    ! Set Auto Brightness: manual
                                                  ! brightness control is off,
                                                  ! rely on ambient
    { KEY_DISPLAY_OFF                    245 }   ! display device to off state
    { KEY_WWAN                           246 }   ! Wireless WAN (LTE, UMTS, GSM, etc.)
    { KEY_RFKILL                         247 }   ! Key that controls all radios
    { KEY_MICMUTE                        248 }   ! Mute / unmute the microphone
! Code 255 is reserved for special needs of AT keyboard driver
    { BTN_0                        0x100 }
    { BTN_1                        0x101 }
    { BTN_2                        0x102 }
    { BTN_3                        0x103 }
    { BTN_4                        0x104 }
    { BTN_5                        0x105 }
    { BTN_6                        0x106 }
    { BTN_7                        0x107 }
    { BTN_8                        0x108 }
    { BTN_9                        0x109 }
    { BTN_MOUSE                    0x110 }
    { BTN_LEFT                     0x110 }
    { BTN_RIGHT                    0x111 }
    { BTN_MIDDLE                   0x112 }
    { BTN_SIDE                     0x113 }
    { BTN_EXTRA                    0x114 }
    { BTN_FORWARD                  0x115 }
    { BTN_BACK                     0x116 }
    { BTN_TASK                     0x117 }
    { BTN_TRIGGER                  0x120 }
    { BTN_JOYSTICK                 0x120 } ! Button 1
    { BTN_THUMB                    0x121 }
    { BTN_THUMB2                   0x122 }
    { BTN_TOP                      0x123 }
    { BTN_TOP2                     0x124 }
    { BTN_PINKIE                   0x125 }
    { BTN_BASE                     0x126 }
    { BTN_BASE2                    0x127 }
    { BTN_BASE3                    0x128 }
    { BTN_BASE4                    0x129 }
    { BTN_BASE5                    0x12a }
    { BTN_BASE6                    0x12b }
    { BTN_BASE7                    0x12c } ! not defined by linux
    { BTN_BASE8                    0x12d } ! not defined by linux
    { BTN_BASE9                    0x12e } ! not defined by linux
    { BTN_DEAD                     0x12f }
    { BTN_A                        0x130 }
    { BTN_B                        0x131 }
    { BTN_C                        0x132 }
    { BTN_X                        0x133 }
    { BTN_Y                        0x134 }
    { BTN_Z                        0x135 }
    { BTN_TL                       0x136 }
    { BTN_TR                       0x137 }
    { BTN_TL2                      0x138 }
    { BTN_TR2                      0x139 }
    { BTN_SELECT                   0x13a }
    { BTN_START                    0x13b }
    { BTN_MODE                     0x13c }
    { BTN_THUMBL                   0x13d }
    { BTN_THUMBR                   0x13e }
    { BTN_TOOL_PEN                 0x140 }
    { BTN_TOOL_RUBBER              0x141 }
    { BTN_TOOL_BRUSH               0x142 }
    { BTN_TOOL_PENCIL              0x143 }
    { BTN_TOOL_AIRBRUS             0x144 }
    { BTN_TOOL_FINGER              0x145 }
    { BTN_TOOL_MOUSE               0x146 }
    { BTN_TOOL_LENS                0x147 }
    { BTN_TOOL_QUINTTA             0x148 }    ! Five fingers on trackpad
    { BTN_STYLUS3                  0x149 }
    { BTN_TOUCH                    0x14a }
    { BTN_STYLUS                   0x14b }
    { BTN_STYLUS2                  0x14c }
    { BTN_TOOL_DOUBLETAP           0x14d }
    { BTN_TOOL_TRIPLETAP           0x14e }
    { BTN_TOOL_QUADTAP             0x14f }    ! Four fingers on trackpad
    { BTN_WHEEL                    0x150 }
    { BTN_GEAR_DOWN                0x150 }
    { BTN_GEAR_UP                  0x151 }
    { KEY_OK                       0x160 }
    { KEY_SELECT                   0x161 }
    { KEY_GOTO                     0x162 }
    { KEY_CLEAR                    0x163 }
    { KEY_POWER2                   0x164 }
    { KEY_OPTION                   0x165 }
    { KEY_INFO                     0x166 }    ! AL OEM Features/Tips/Tutorial
    { KEY_TIME                     0x167 }
    { KEY_VENDOR                   0x168 }
    { KEY_ARCHIVE                  0x169 }
    { KEY_PROGRAM                  0x16a }    ! Media Select Program Guide
    { KEY_CHANNEL                  0x16b }
    { KEY_FAVORITES                0x16c }
    { KEY_EPG                      0x16d }
    { KEY_PVR                      0x16e }    ! Media Select Home
    { KEY_MHP                      0x16f }
    { KEY_LANGUAGE                 0x170 }
    { KEY_TITLE                    0x171 }
    { KEY_SUBTITLE                 0x172 }
    { KEY_ANGLE                    0x173 }
    { KEY_ZOOM                     0x174 }
    { KEY_MODE                     0x175 }
    { KEY_KEYBOARD                 0x176 }
    { KEY_SCREEN                   0x177 }
    { KEY_PC                       0x178 }    ! Media Select Computer
    { KEY_TV                       0x179 }    ! Media Select TV
    { KEY_TV2                      0x17a }    ! Media Select Cable
    { KEY_VCR                      0x17b }    ! Media Select VCR
    { KEY_VCR2                     0x17c }    ! VCR Plus
    { KEY_SAT                      0x17d }    ! Media Select Satellite
    { KEY_SAT2                     0x17e }
    { KEY_CD                       0x17f }    ! Media Select CD
    { KEY_TAPE                     0x180 }    ! Media Select Tape
    { KEY_RADIO                    0x181 }
    { KEY_TUNER                    0x182 }    ! Media Select Tuner
    { KEY_PLAYER                   0x183 }
    { KEY_TEXT                     0x184 }
    { KEY_DVD                      0x185 }    ! Media Select DVD
    { KEY_AUX                      0x186 }
    { KEY_MP3                      0x187 }
    { KEY_AUDIO                    0x188 }    ! AL Audio Browser
    { KEY_VIDEO                    0x189 }    ! AL Movie Browser
    { KEY_DIRECTORY                0x18a }
    { KEY_LIST                     0x18b }
    { KEY_MEMO                     0x18c }    ! Media Select Messages
    { KEY_CALENDAR                 0x18d }
    { KEY_RED                      0x18e }
    { KEY_GREEN                    0x18f }
    { KEY_YELLOW                   0x190 }
    { KEY_BLUE                     0x191 }
    { KEY_CHANNELUP                0x192 }    ! Channel Increment
    { KEY_CHANNELDOWN              0x193 }    ! Channel Decrement
    { KEY_FIRST                    0x194 }
    { KEY_LAST                     0x195 }    ! Recall Last
    { KEY_AB                       0x196 }
    { KEY_NEXT                     0x197 }
    { KEY_RESTART                  0x198 }
    { KEY_SLOW                     0x199 }
    { KEY_SHUFFLE                  0x19a }
    { KEY_BREAK                    0x19b }
    { KEY_PREVIOUS                 0x19c }
    { KEY_DIGITS                   0x19d }
    { KEY_TEEN                     0x19e }
    { KEY_TWEN                     0x19f }
    { KEY_VIDEOPHONE               0x1a0 }    ! Media Select Video Phone
    { KEY_GAMES                    0x1a1 }    ! Media Select Games
    { KEY_ZOOMIN                   0x1a2 }    ! AC Zoom In
    { KEY_ZOOMOUT                  0x1a3 }    ! AC Zoom Out
    { KEY_ZOOMRESET                0x1a4 }    ! AC Zoom
    { KEY_WORDPROCESSOR            0x1a5 }    ! AL Word Processor
    { KEY_EDITOR                   0x1a6 }    ! AL Text Editor
    { KEY_SPREADSHEET              0x1a7 }    ! AL Spreadsheet
    { KEY_GRAPHICSEDITOR           0x1a8 }    ! AL Graphics Editor
    { KEY_PRESENTATION             0x1a9 }    ! AL Presentation App
    { KEY_DATABASE                 0x1aa }    ! AL Database App
    { KEY_NEWS                     0x1ab }    ! AL Newsreader
    { KEY_VOICEMAIL                0x1ac }    ! AL Voicemail
    { KEY_ADDRESSBOOK              0x1ad }    ! AL Contacts/Address Book
    { KEY_MESSENGER                0x1ae }    ! AL Instant Messaging
    { KEY_DISPLAYTOGGLE            0x1af }    ! Turn display (LCD) on and off
    { KEY_SPELLCHECK               0x1b0 }    ! AL Spell Check
    { KEY_LOGOFF                   0x1b1 }    ! AL Logoff
    { KEY_DOLLAR                   0x1b2 }
    { KEY_EURO                     0x1b3 }
    { KEY_FRAMEBACK                0x1b4 }    ! Consumer - transport controls
    { KEY_FRAMEFORWARD             0x1b5 }
    { KEY_CONTEXT_MENU             0x1b6 }    ! GenDesc - system context menu
    { KEY_MEDIA_REPEAT             0x1b7 }    ! Consumer - transport control
    { KEY_10CHANNELSUP             0x1b8 }    ! 10 channels up (10+)
    { KEY_10CHANNELSDOWN           0x1b9 }    ! 10 channels down (10-)
    { KEY_IMAGES                   0x1ba }    ! AL Image Browser
    { KEY_DEL_EOL                  0x1c0 }
    { KEY_DEL_EOS                  0x1c1 }
    { KEY_INS_LINE                 0x1c2 }
    { KEY_DEL_LINE                 0x1c3 }
    { KEY_FN                       0x1d0 }
    { KEY_FN_ESC                   0x1d1 }
    { KEY_FN_F1                    0x1d2 }
    { KEY_FN_F2                    0x1d3 }
    { KEY_FN_F3                    0x1d4 }
    { KEY_FN_F4                    0x1d5 }
    { KEY_FN_F5                    0x1d6 }
    { KEY_FN_F6                    0x1d7 }
    { KEY_FN_F7                    0x1d8 }
    { KEY_FN_F8                    0x1d9 }
    { KEY_FN_F9                    0x1da }
    { KEY_FN_F10                   0x1db }
    { KEY_FN_F11                   0x1dc }
    { KEY_FN_F12                   0x1dd }
    { KEY_FN_1                     0x1de }
    { KEY_FN_2                     0x1df }
    { KEY_FN_D                     0x1e0 }
    { KEY_FN_E                     0x1e1 }
    { KEY_FN_F                     0x1e2 }
    { KEY_FN_S                     0x1e3 }
    { KEY_FN_B                     0x1e4 }
    { KEY_BRL_DOT1                 0x1f1 }
    { KEY_BRL_DOT2                 0x1f2 }
    { KEY_BRL_DOT3                 0x1f3 }
    { KEY_BRL_DOT4                 0x1f4 }
    { KEY_BRL_DOT5                 0x1f5 }
    { KEY_BRL_DOT6                 0x1f6 }
    { KEY_BRL_DOT7                 0x1f7 }
    { KEY_BRL_DOT8                 0x1f8 }
    { KEY_BRL_DOT9                 0x1f9 }
    { KEY_BRL_DOT10                0x1fa }
    { KEY_NUMERIC_0                0x200 }    ! used by phones, remote controls,
    { KEY_NUMERIC_1                0x201 }    ! and other keypads
    { KEY_NUMERIC_2                0x202 }
    { KEY_NUMERIC_3                0x203 }
    { KEY_NUMERIC_4                0x204 }
    { KEY_NUMERIC_5                0x205 }
    { KEY_NUMERIC_6                0x206 }
    { KEY_NUMERIC_7                0x207 }
    { KEY_NUMERIC_8                0x208 }
    { KEY_NUMERIC_9                0x209 }
    { KEY_NUMERIC_STAR             0x20a }
    { KEY_NUMERIC_POUND            0x20b }
    { KEY_NUMERIC_A                0x20c }    ! Phone key A - HUT Telephony 0xb9
    { KEY_NUMERIC_B                0x20d }
    { KEY_NUMERIC_C                0x20e }
    { KEY_NUMERIC_D                0x20f }
    { KEY_CAMERA_FOCUS             0x210 }
    { KEY_WPS_BUTTON               0x211 }    ! WiFi Protected Setup key
    { KEY_TOUCHPAD_TOGGLE          0x212 }    ! Request switch touchpad on or off
    { KEY_TOUCHPAD_ON              0x213 }
    { KEY_TOUCHPAD_OFF             0x214 }
    { KEY_CAMERA_ZOOMIN            0x215 }
    { KEY_CAMERA_ZOOMOUT           0x216 }
    { KEY_CAMERA_UP                0x217 }
    { KEY_CAMERA_DOWN              0x218 }
    { KEY_CAMERA_LEFT              0x219 }
    { KEY_CAMERA_RIGHT             0x21a }
    { KEY_ATTENDANT_ON             0x21b }
    { KEY_ATTENDANT_OFF            0x21c }
    { KEY_ATTENDANT_TOGGLE         0x21d }    ! Attendant call on or off
    { KEY_LIGHTS_TOGGLE            0x21e }    ! Reading light on or off
    { BTN_DPAD_UP                  0x220 }
    { BTN_DPAD_DOWN                0x221 }
    { BTN_DPAD_LEFT                0x222 }
    { BTN_DPAD_RIGHT               0x223 }
    { KEY_ALS_TOGGLE               0x230 }    ! Ambient light sensor
    { KEY_ROTATE_LOCK_TOGGLE       0x231 }    ! Display rotation lock
    { KEY_BUTTONCONFIG             0x240 }    ! AL Button Configuration
    { KEY_TASKMANAGER              0x241 }    ! AL Task/Project Manager
    { KEY_JOURNAL                  0x242 }    ! AL Log/Journal/Timecard
    { KEY_CONTROLPANEL             0x243 }    ! AL Control Panel
    { KEY_APPSELECT                0x244 }    ! AL Select Task/Application
    { KEY_SCREENSAVER              0x245 }    ! AL Screen Saver
    { KEY_VOICECOMMAND             0x246 }    ! Listening Voice Command
    { KEY_ASSISTANT                0x247 }    ! AL Context-aware desktop assistant
    { KEY_BRIGHTNESS_MIN           0x250 }    ! Set Brightness to Minimum
    { KEY_BRIGHTNESS_MAX           0x251 }    ! Set Brightness to Maximum
    { KEY_KBDINPUTASSIST_PREV      0x260 }
    { KEY_KBDINPUTASSIST_NEXT      0x261 }
    { KEY_KBDINPUTASSIST_PREVGROUP 0x262 }
    { KEY_KBDINPUTASSIST_NEXTGROUP 0x263 }
    { KEY_KBDINPUTASSIST_ACCEPT    0x264 }
    { KEY_KBDINPUTASSIST_CANCEL    0x265 }
! Diagonal movement keys
    { KEY_RIGHT_UP                 0x266 }
    { KEY_RIGHT_DOWN               0x267 }
    { KEY_LEFT_UP                  0x268 }
    { KEY_LEFT_DOWN                0x269 }
    { KEY_ROOT_MENU                0x26a }    ! Show Device's Root Menu
! Show Top Menu of the Media (e.g. DVD)
    { KEY_MEDIA_TOP_MENU           0x26b }
    { KEY_NUMERIC_11               0x26c }
    { KEY_NUMERIC_12               0x26d }
! Toggle Audio Description: refers to an audio service that helps blind and
! visually impaired consumers understand the action in a program. Note: in
! some countries this is referred to as "Video Description".
    { KEY_AUDIO_DESC               0x26e }
    { KEY_3D_MODE                  0x26f }
    { KEY_NEXT_FAVORITE            0x270 }
    { KEY_STOP_RECORD              0x271 }
    { KEY_PAUSE_RECORD             0x272 }
    { KEY_VOD                      0x273 }    ! Video on Demand
    { KEY_UNMUTE                   0x274 }
    { KEY_FASTREVERSE              0x275 }
    { KEY_SLOWREVERSE              0x276 }
! Control a data application associated with the currently viewed channel,
! e.g. teletext or data broadcast application (MHEG, MHP, HbbTV, etc.)
    { KEY_DATA                     0x277 }
    { KEY_ONSCREEN_KEYBOARD        0x278 }
    { BTN_TRIGGER_HAPPY            0x2c0 }
    { BTN_TRIGGER_HAPPY1           0x2c0 }
    { BTN_TRIGGER_HAPPY2           0x2c1 }
    { BTN_TRIGGER_HAPPY3           0x2c2 }
    { BTN_TRIGGER_HAPPY4           0x2c3 }
    { BTN_TRIGGER_HAPPY5           0x2c4 }
    { BTN_TRIGGER_HAPPY6           0x2c5 }
    { BTN_TRIGGER_HAPPY7           0x2c6 }
    { BTN_TRIGGER_HAPPY8           0x2c7 }
    { BTN_TRIGGER_HAPPY9           0x2c8 }
    { BTN_TRIGGER_HAPPY10          0x2c9 }
    { BTN_TRIGGER_HAPPY11          0x2ca }
    { BTN_TRIGGER_HAPPY12          0x2cb }
    { BTN_TRIGGER_HAPPY13          0x2cc }
    { BTN_TRIGGER_HAPPY14          0x2cd }
    { BTN_TRIGGER_HAPPY15          0x2ce }
    { BTN_TRIGGER_HAPPY16          0x2cf }
    { BTN_TRIGGER_HAPPY17          0x2d0 }
    { BTN_TRIGGER_HAPPY18          0x2d1 }
    { BTN_TRIGGER_HAPPY19          0x2d2 }
    { BTN_TRIGGER_HAPPY20          0x2d3 }
    { BTN_TRIGGER_HAPPY21          0x2d4 }
    { BTN_TRIGGER_HAPPY22          0x2d5 }
    { BTN_TRIGGER_HAPPY23          0x2d6 }
    { BTN_TRIGGER_HAPPY24          0x2d7 }
    { BTN_TRIGGER_HAPPY25          0x2d8 }
    { BTN_TRIGGER_HAPPY26          0x2d9 }
    { BTN_TRIGGER_HAPPY27          0x2da }
    { BTN_TRIGGER_HAPPY28          0x2db }
    { BTN_TRIGGER_HAPPY29          0x2dc }
    { BTN_TRIGGER_HAPPY30          0x2dd }
    { BTN_TRIGGER_HAPPY31          0x2de }
    { BTN_TRIGGER_HAPPY32          0x2df }
    { BTN_TRIGGER_HAPPY33          0x2e0 }
    { BTN_TRIGGER_HAPPY34          0x2e1 }
    { BTN_TRIGGER_HAPPY35          0x2e2 }
    { BTN_TRIGGER_HAPPY36          0x2e3 }
    { BTN_TRIGGER_HAPPY37          0x2e4 }
    { BTN_TRIGGER_HAPPY38          0x2e5 }
    { BTN_TRIGGER_HAPPY39          0x2e6 }
    { BTN_TRIGGER_HAPPY40          0x2e7 }
! We avoid low common keys in module aliases so they don't get huge.
    { KEY_MAX                      0x2ff }
    { KEY_CNT                      0x300 } ;    ! (KEY_MAX+1)

CONSTANT: BTN_GAMEPAD              0x130
CONSTANT: BTN_DIGI                 0x140
CONSTANT: KEY_MIN_INTERESTING      KEY_MUTE
CONSTANT: KEY_HANGUEL              KEY_HANGEUL
CONSTANT: KEY_SCREENLOCK           KEY_COFFEE
CONSTANT: KEY_DIRECTION            KEY_ROTATE_DISPLAY
CONSTANT: KEY_BRIGHTNESS_ZERO      KEY_BRIGHTNESS_AUTO
CONSTANT: KEY_WIMAX                KEY_WWAN
CONSTANT: KEY_BRIGHTNESS_TOGGLE    KEY_DISPLAYTOGGLE
CONSTANT: BTN_MISC                 0x100
CONSTANT: BTN_SOUTH                BTN_A
CONSTANT: BTN_EAST                 BTN_B
CONSTANT: BTN_NORTH                BTN_X
CONSTANT: BTN_WEST                 BTN_Y

! Relative axes
! 3rd param
ENUM: INPUT_REL
    { REL_X                        0x00 }
    { REL_Y                        0x01 }
    { REL_Z                        0x02 }
    { REL_RX                       0x03 }
    { REL_RY                       0x04 }
    { REL_RZ                       0x05 }
    { REL_HWHEEL                   0x06 }
    { REL_DIAL                     0x07 }
    { REL_WHEEL                    0x08 }
    { REL_MISC                     0x09 }
    { REL_RESERVED                 0x0a }
    { REL_WHEEL_HI_RES             0x0b }
    { REL_HWHEEL_HI_RES            0x0c }
    { REL_MAX                      0x0f }
    { REL_CNT                      0x10 } ;     ! (REL_MAX+1)

! Absolute axes
ENUM: INPUT_ABS
    { ABS_X                        0x00 }
    { ABS_Y                        0x01 }
    { ABS_Z                        0x02 }
    { ABS_RX                       0x03 }
    { ABS_RY                       0x04 }
    { ABS_RZ                       0x05 }
    { ABS_THROTTLE                 0x06 }
    { ABS_RUDDER                   0x07 }
    { ABS_WHEEL                    0x08 }
    { ABS_GAS                      0x09 }
    { ABS_BRAKE                    0x0a }
    { ABS_HAT0X                    0x10 }
    { ABS_HAT0Y                    0x11 }
    { ABS_HAT1X                    0x12 }
    { ABS_HAT1Y                    0x13 }
    { ABS_HAT2X                    0x14 }
    { ABS_HAT2Y                    0x15 }
    { ABS_HAT3X                    0x16 }
    { ABS_HAT3Y                    0x17 }
    { ABS_PRESSURE                 0x18 }
    { ABS_DISTANCE                 0x19 }
    { ABS_TILT_X                   0x1a }
    { ABS_TILT_Y                   0x1b }
    { ABS_TOOL_WIDTH               0x1c }
    { ABS_VOLUME                   0x20 }
    { ABS_MISC                     0x28 }
    { ABS_MT_SLOT                  0x2f }    ! MT slot being modified
    { ABS_MT_TOUCH_MAJOR           0x30 }    ! Major axis of touching ellipse
    { ABS_MT_TOUCH_MINOR           0x31 }    ! Minor axis (omit if circular)
    { ABS_MT_WIDTH_MAJOR           0x32 }    ! Major axis of approaching ellipse
    { ABS_MT_WIDTH_MINOR           0x33 }    ! Minor axis (omit if circular)
    { ABS_MT_ORIENTATION           0x34 }    ! Ellipse orientation
    { ABS_MT_POSITION_X            0x35 }    ! Center X touch position
    { ABS_MT_POSITION_Y            0x36 }    ! Center Y touch position
    { ABS_MT_TOOL_TYPE             0x37 }    ! Type of touching device
    { ABS_MT_BLOB_ID               0x38 }    ! Group a set of packets as a blob
    { ABS_MT_TRACKING_ID           0x39 }    ! Unique ID of initiated contact
    { ABS_MT_PRESSURE              0x3a }    ! Pressure on contact area
    { ABS_MT_DISTANCE              0x3b }    ! Contact hover distance
    { ABS_MT_TOOL_X                0x3c }    ! Center X tool position
    { ABS_MT_TOOL_Y                0x3d }    ! Center Y tool position
    { ABS_MAX                      0x3f }
    { ABS_CNT                      0x40 } ;    ! (ABS_MAX+1)

! Switch events
ENUM: INPUT_SW
    { SW_LID                       0x00 }    ! set = lid shut
    { SW_TABLET_MODE               0x01 }    ! set = tablet mode
    { SW_HEADPHONE_INSERT          0x02 }    ! set = inserted
    { SW_RFKILL_ALL                0x03 }    ! rfkill master switch, type "any"
                                             ! set = radio enabled
    { SW_MICROPHONE_INSERT         0x04 }    ! set = inserted
    { SW_DOCK                      0x05 }    ! set = plugged into dock
    { SW_LINEOUT_INSERT            0x06 }    ! set = inserted
    { SW_JACK_PHYSICAL_INSERT      0x07 }    ! set = mechanical switch set
    { SW_VIDEOOUT_INSERT           0x08 }    ! set = inserted
    { SW_CAMERA_LENS_COVER         0x09 }    ! set = lens covered
    { SW_KEYPAD_SLIDE              0x0a }    ! set = keypad slide out
    { SW_FRONT_PROXIMITY           0x0b }    ! set = front proximity sensor active
    { SW_ROTATE_LOCK               0x0c }    ! set = rotate locked/disabled
    { SW_LINEIN_INSERT             0x0d }    ! set = inserted
    { SW_MUTE_DEVICE               0x0e }    ! set = device disabled
    { SW_PEN_INSERTED              0x0f }    ! set = pen inserted
    { SW_MAX                       0x0f }
    { SW_CNT                       0x10 } ;  ! (SW_MAX+1)

CONSTANT: SW_RADIO                     SW_RFKILL_ALL  ! deprecated

! Misc events
ENUM: INPUT_MSC
    { MSC_SERIAL                   0x00 }
    { MSC_PULSELED                 0x01 }
    { MSC_GESTURE                  0x02 }
    { MSC_RAW                      0x03 }
    { MSC_SCAN                     0x04 }
    { MSC_TIMESTAMP                0x05 }
    { MSC_MAX                      0x07 }
    { MSC_CNT                      0x08 } ;  ! (MSC_MAX+1)

ENUM: SCANCODES
    { SCANCODE_BTN_LEFT 589825 }
    { SCANCODE_BTN_RIGHT 589826 }
    { SCANCODE_BTN_MIDDLE 589827 }
    { SCANCODE_BTN_SIDE 589828 }
    { SCANCODE_BTN_EXTRA 589829 } ;

! LEDs
ENUM: INPUT_LED
    { LED_NUML                     0x00 }
    { LED_CAPSL                    0x01 }
    { LED_SCROLLL                  0x02 }
    { LED_COMPOSE                  0x03 }
    { LED_KANA                     0x04 }
    { LED_SLEEP                    0x05 }
    { LED_SUSPEND                  0x06 }
    { LED_MUTE                     0x07 }
    { LED_MISC                     0x08 }
    { LED_MAIL                     0x09 }
    { LED_CHARGING                 0x0a }
    { LED_MAX                      0x0f }
    { LED_CNT                      0x10 } ;  ! (LED_MAX+1)

! Autorepeat values
ENUM: INPUT_REP
    { REP_DELAY                    0x00 }
    { REP_PERIOD                   0x01 }
    { REP_MAX                      0x01 }
    { REP_CNT                      0x02 } ;  ! (REP_MAX+1)

! Sounds
ENUM: INPUT_SND
    { SND_CLICK                    0x00 }
    { SND_BELL                     0x01 }
    { SND_TONE                     0x02 }
    { SND_MAX                      0x07 }
    { SND_CNT                      0x08 } ;  ! (SND_MAX+1)

! Force feedback effect types
ENUM: INPUT_FF
    { FF_RUMBLE 0x50 }
    { FF_PERIODIC 0x51 }
    { FF_CONSTANT 0x52 }
    { FF_SPRING 0x53 }
    { FF_FRICTION 0x54 }
    { FF_DAMPER 0x55 }
    { FF_INERTIA  0x56 }
    { FF_RAMP   0x57 }

! FF_EFFECT_MIN FF_RUMBLE
! FF_EFFECT_MAX FF_RAMP

! Force feedback periodic effect types

    { FF_SQUARE 0x58 }
    { FF_TRIANGLE 0x59 }
    { FF_SINE   0x5a                                                                                                                      }
    { FF_SAW_UP 0x5b }
    { FF_SAW_DOWN 0x5c }
    { FF_CUSTOM 0x5d }

! FF_WAVEFORM_MIN FF_SQUARE
! FF_WAVEFORM_MAX FF_CUSTOM
! Set ff device properties
    { FF_GAIN   0x60 }
    { FF_AUTOCENTER 0x61 }

! ff->playback(effect_id = FF_GAIN) is the first effect_id to
! cause a collision with another ff method, in this case ff->set_gain().
! Therefore the greatest safe value for effect_id is FF_GAIN - 1,
! and thus the total number of effects should never exceed FF_GAIN.

! FF_MAX_EFFECTS  FF_GAIN
    { FF_MAX    0x7f }
    { FF_CNT    0x80 } ;

ENUM: FF_STATUS
    { FF_STATUS_STOPPED 0x00 }
    { FF_STATUS_PLAYING 0x01 }
    { FF_STATUS_MAX   0x01 } ;

