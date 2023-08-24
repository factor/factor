USING: game.input math math.order kernel macros fry sequences quotations
arrays windows.directx.xinput combinators accessors windows.types
game.input.dinput sequences.private namespaces classes.struct
windows.errors windows.com.syntax alien.strings ;
IN: game.input.xinput

SINGLETON: xinput-game-input-backend

xinput-game-input-backend game-input-backend set-global

<PRIVATE
: >axis ( short -- float )
    32768 /f ; inline
: >trigger ( byte -- float )
    255 /f ; inline
: >vibration ( float -- short )
    65535 * >fixnum 0 65535 clamp ; inline
MACRO: map-index-compose ( seq quot -- quot' )
    '[ '[ _ execute _ ] _ compose ] map-index 1quotation ;

: fill-buttons ( button-bitmap -- button-array )
    10 0.0 <array> dup rot >fixnum
    { XINPUT_GAMEPAD_START
      XINPUT_GAMEPAD_BACK
      XINPUT_GAMEPAD_LEFT_THUMB
      XINPUT_GAMEPAD_RIGHT_THUMB
      XINPUT_GAMEPAD_LEFT_SHOULDER
      XINPUT_GAMEPAD_RIGHT_SHOULDER
      XINPUT_GAMEPAD_A
      XINPUT_GAMEPAD_B
      XINPUT_GAMEPAD_X
      XINPUT_GAMEPAD_Y }
      [ [ bitand ] dip swap 0 = [ 2drop ] [ [ 1.0 ] 2dip swap set-nth ] if ]
      map-index-compose 2cleave ;

: >pov ( byte -- symbol )
    {
         pov-neutral
         pov-up
         pov-down
         pov-neutral
         pov-left
         pov-up-left
         pov-down-left
         pov-neutral
         pov-right
         pov-up-right
         pov-down-right
         pov-neutral
         pov-neutral
         pov-neutral
         pov-neutral
         pov-neutral
    } nth ;

: fill-controller-state ( XINPUT_STATE -- controller-state )
    Gamepad>> controller-state new dup rot
    {
        [ wButtons>> 0xf bitand >pov swap pov<< ]
        [ wButtons>> fill-buttons swap buttons<< ]
        [ sThumbLX>> >axis swap x<< ]
        [ sThumbLY>> >axis swap y<< ]
        [ sThumbRX>> >axis swap rx<< ]
        [ sThumbRY>> >axis swap ry<< ]
        [ bLeftTrigger>> >trigger swap z<< ]
        [ bRightTrigger>> >trigger swap rz<< ]
    } 2cleave ;
PRIVATE>

M: xinput-game-input-backend (open-game-input)
    TRUE XInputEnable
    create-dinput
    create-device-change-window
    find-keyboard
    find-mouse
    add-wm-devicechange ;

M: xinput-game-input-backend (close-game-input)
    remove-wm-devicechange
    release-mouse
    release-keyboard
    close-device-change-window
    delete-dinput
    FALSE XInputEnable ;

M: xinput-game-input-backend (reset-game-input)
    [
        {
            +dinput+ +keyboard-device+ +keyboard-state+
            +controller-devices+ +controller-guids+
            +device-change-window+ +device-change-handle+
        } [ off ] each
    ] with-global ;

M: xinput-game-input-backend get-controllers
    { 0 1 2 3 } ;

M: xinput-game-input-backend product-string
    dup number?
    [ drop "Controller (Xbox 360 Wireless Receiver for Windows)" ]
    [ handle>> device-info tszProductName>> alien>native-string ]
    if ;

M: xinput-game-input-backend product-id
    dup number?
    [ drop GUID: {02a1045e-0000-0000-0000-504944564944} ]
    [ handle>> device-info guidProduct>> ]
    if ;

M: xinput-game-input-backend instance-id
    dup number?
    [ drop GUID: {c6075b30-fbca-11de-8001-444553540000} ]
    [ handle>> device-guid ]
    if ;

M: xinput-game-input-backend read-controller
    XINPUT_STATE new [ XInputGetState drop ] keep
    fill-controller-state ;

M: xinput-game-input-backend calibrate-controller drop ;

M: xinput-game-input-backend vibrate-controller
    [ >vibration ] bi@ XINPUT_VIBRATION boa XInputSetState drop ;

M: xinput-game-input-backend read-keyboard
    +keyboard-device+ get
    [ +keyboard-state+ get [ keys>> underlying>> get-device-state ] keep ]
    [ ] [ f ] with-acquisition ;

M: xinput-game-input-backend read-mouse
    +mouse-device+ get [ +mouse-buffer+ get MOUSE-BUFFER-SIZE read-device-buffer ]
    [ fill-mouse-state ] [ f ] with-acquisition ;

M: xinput-game-input-backend reset-mouse
    +mouse-device+ get [ f MOUSE-BUFFER-SIZE read-device-buffer ]
    [ 2drop ] [ ] with-acquisition
    +mouse-state+ get
        0 >>dx
        0 >>dy
        0 >>scroll-dx
        0 >>scroll-dy
        drop ;
