USING: windows.dinput windows.dinput.constants game-input
symbols alien.c-types windows.ole32 namespaces assocs kernel
arrays hashtables windows.kernel32 windows.com windows.dinput
shuffle windows.user32 windows.messages sequences combinators
math.geometry.rect ui.windows accessors math windows
alien.strings io.encodings.utf16 ;
IN: game-input.backend.dinput

SINGLETON: dinput-game-input-backend

SYMBOLS: +dinput+ +keyboard-device+ +controller-devices+
    +device-change-window+ +device-change-handle+ ;

: create-dinput ( -- )
    f GetModuleHandle DIRECTINPUT_VERSION IDirectInput8W-iid
    f <void*> [ f DirectInput8Create ole32-error ] keep *void*
    +dinput+ set-global ;

: delete-dinput ( -- )
    +dinput+ global [ com-release f ] change-at ;

: device-for-guid ( guid -- device )
    +dinput+ get swap f <void*>
    [ f IDirectInput8W::CreateDevice ole32-error ] keep *void* ;

: set-coop-level ( device -- device )
    dup +device-change-window+ get DISCL_BACKGROUND DISCL_NONEXCLUSIVE bitor
    IDirectInputDevice8W::SetCooperativeLevel ole32-error ;

: configure-keyboard ( keyboard -- keyboard )
    dup c_dfDIKeyboard_HID IDirectInputDevice8W::SetDataFormat
    ole32-error set-coop-level ;
: configure-controller ( controller -- controller )
    dup c_dfDIJoystick2 IDirectInputDevice8W::SetDataFormat
    ole32-error set-coop-level ;

: find-keyboard ( -- )
    GUID_SysKeyboard get device-for-guid
    configure-keyboard
    +keyboard-device+ set-global ;

: device-info ( device -- DIDEVICEIMAGEINFOW )
    "DIDEVICEINSTANCEW" <c-object>
    "DIDEVICEINSTANCEW" heap-size over set-DIDEVICEINSTANCEW-dwSize
    [ IDirectInputDevice8W::GetDeviceInfo ole32-error ] keep ;

: controller-device? ( device -- ? )
    device-info
    DIDEVICEINSTANCEW-dwDevType GET_DIDEVICE_TYPE
    DI8DEVTYPE_KEYBOARD DI8DEVTYPE_MOUSE 2array member? not ;

: device-attached? ( guid -- ? )
    +dinput+ get swap IDirectInput8W::GetDeviceStatus
    [ ole32-error ] [ S_OK = ] bi ;

: <guid> ( memory -- byte-array )
    "GUID" heap-size memory>byte-array ;

: add-controller ( guid -- )
    [ device-for-guid configure-controller ] [ <guid> ] bi
    over controller-device?
    [ +controller-devices+ get set-at ]
    [ drop com-release ] if ;

: remove-controller ( guid -- )
    <guid> +controller-devices+ get [ com-release f ] change-at ;

: find-controller-callback ( -- alien )
    [ ! ( lpddi pvRef -- ? )
        drop DIDEVICEINSTANCEW-guidInstance add-controller
        DIENUM_CONTINUE
    ] LPDIENUMDEVICESCALLBACKW ;

: find-controllers ( -- )
    4 <hashtable> +controller-devices+ set-global
    +dinput+ get DI8DEVCLASS_GAMECTRL find-controller-callback
    f DIEDFL_ATTACHEDONLY IDirectInput8W::EnumDevices ole32-error ;

: find-device ( DEV_BROADCAST_DEVICEW -- guid/f )
    +dinput+ get swap
    [ DEV_BROADCAST_DEVICEW-dbcc_classguid ]
    [ DEV_BROADCAST_DEVICEW-dbcc_name ] bi
    f <void*>
    [ IDirectInput8W::FindDevice ] keep *void*
    swap succeeded? [ drop f ] unless ;

: find-and-add-device ( DEV_BROADCAST_DEVICEW -- )
    find-device [ add-controller ] when* ;
: find-and-remove-detached-devices ( -- )
    +controller-devices+ get [
        drop dup device-attached? [ drop ] [ remove-controller ] if
    ] assoc-each ;

: device-interface? ( dbt-broadcast-hdr -- ? )
    DEV_BROADCAST_HDR-dbch_devicetype DBT_DEVTYP_DEVICEINTERFACE = ;

: device-arrived ( dbt-broadcast-hdr -- )
    dup device-interface? [ find-and-add-device ] [ drop ] if ;

: device-removed ( dbt-broadcast-hdr -- )
    device-interface? [ find-and-remove-detached-devices ] when ;

: handle-wm-devicechange ( hWnd uMsg wParam lParam -- )
    [ 2drop ] 2dip swap {
        { [ dup DBT_DEVICEARRIVAL = ]         [ drop device-arrived ] }
        { [ dup DBT_DEVICEREMOVECOMPLETE = ]  [ drop device-removed ] }
        [ 2drop ]
    } cond ;

TUPLE: window-rect < rect window-loc ;
: <zero-window-rect> ( -- window-rect )
    window-rect new
    { 0 0 } >>window-loc
    { 0 0 } >>loc
    { 0 0 } >>dim ;

: (device-notification-filter) ( -- DEV_BROADCAST_DEVICEW )
    "DEV_BROADCAST_DEVICEW" <c-object>
    "DEV_BROADCAST_DEVICEW" heap-size over set-DEV_BROADCAST_DEVICEW-dbcc_size
    DBT_DEVTYP_DEVICEINTERFACE over set-DEV_BROADCAST_DEVICEW-dbcc_devicetype ;

: create-device-change-window ( -- )
    <zero-window-rect> create-window
    [
        (device-notification-filter)
        DEVICE_NOTIFY_WINDOW_HANDLE DEVICE_NOTIFY_ALL_INTERFACE_CLASSES bitor
        RegisterDeviceNotification
        +device-change-handle+ set-global
    ]
    [ +device-change-window+ set-global ] bi ;

: close-device-change-window ( -- )
    +device-change-handle+ global
    [ UnregisterDeviceNotification drop f ] change-at
    +device-change-window+ global
    [ DestroyWindow win32-error=0/f f ] change-at ;

: add-wm-devicechange ( -- )
    [ 4dup handle-wm-devicechange DefWindowProc ]
    WM_DEVICECHANGE add-wm-handler ;

: remove-wm-devicechange ( -- )
    WM_DEVICECHANGE wm-handlers get-global delete-at ;

: release-controllers ( -- )
    +controller-devices+ global [
        [ nip com-release ] assoc-each f
    ] change-at ;

: release-keyboard ( -- )
    +keyboard-device+ global
    [ com-release f ] change-at ;

M: dinput-game-input-backend open-game-input
    create-dinput
    create-device-change-window
    find-keyboard
    find-controllers
    add-wm-devicechange ;

M: dinput-game-input-backend close-game-input
    remove-wm-devicechange
    release-controllers
    release-keyboard
    close-device-change-window
    delete-dinput ;

M: dinput-game-input-backend get-controllers
    +controller-devices+ get
    [ nip controller boa ] { } assoc>map ;

M: dinput-game-input-backend product-string
    handle>> device-info DIDEVICEINSTANCEW-tszProductName
    utf16le alien>string ;

M: dinput-game-input-backend product-id
    handle>> device-info DIDEVICEINSTANCEW-guidProduct <guid> ;
M: dinput-game-input-backend instance-id
    handle>> device-info DIDEVICEINSTANCEW-guidInstance <guid> ;

: with-acquisition ( device quot -- )
    over IDirectInputDevice8W::Acquire ole32-error
    over [ IDirectInputDevice8W::Unacquire ole32-error ] curry
    [ ] cleanup ; inline

: >axis ( long -- float )
    ;
: >slider ( long -- float )
    ;
: >pov ( long -- float )
    ;
: >buttons ( alien -- array )
    128 memory>byte-array [ HEX: 80 bitand c-bool> ] { } map-as ;

: <controller-state> ( DIJOYSTATE2 -- controller-state )
    ! XXX only transfer elements that are present on device
    {
        [ DIJOYSTATE2-lX >axis ]
        [ DIJOYSTATE2-lY >axis ]
        [ DIJOYSTATE2-lZ >axis ]
        [ DIJOYSTATE2-lRx >axis ]
        [ DIJOYSTATE2-lRy >axis ]
        [ DIJOYSTATE2-lRz >axis ]
        [ DIJOYSTATE2-rglSlider *long >slider ]
        [ DIJOYSTATE2-rgdwPOV *uint >pov ]
        [ DIJOYSTATE2-rgbButtons >buttons ]
    } cleave controller-state boa ;

: <keyboard-state> ( byte-array -- keyboard-state )
    [ c-bool> ] { } map-as keyboard-state boa ;

: get-device-state ( device state-size -- byte-array )
    dup <byte-array>
    [ IDirectInputDevice8W::GetDeviceState ole32-error ] keep ;

M: dinput-game-input-backend read-controller
    handle>> [
        "DIJOYSTATE2" heap-size get-device-state
    ] with-acquisition <controller-state> ;

M: dinput-game-input-backend calibrate-controller
    handle>> f 0 IDirectInputDevice8W::RunControlPanel ole32-error ;

M: dinput-game-input-backend read-keyboard
    +keyboard-device+ get [ 
        256 get-device-state
    ] with-acquisition <keyboard-state> ;
