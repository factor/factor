USING: windows.dinput windows.dinput.constants game-input
symbols alien.c-types windows.ole32 namespaces assocs kernel
arrays hashtables windows.kernel32 windows.com windows.dinput
shuffle windows.user32 windows.messages sequences combinators
math.geometry.rect ui.windows accessors math windows ;
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

: configure-keyboard ( keyboard -- keyboard )
    ;
: configure-controller ( controller -- controller )
    ;

: find-keyboard ( -- )
    GUID_SysKeyboard get device-for-guid
    configure-keyboard
    +keyboard-device+ set-global ;

: controller-device? ( device -- ? )
    "DIDEVICEINSTANCEW" <c-object>
    "DIDEVICEINSTANCEW" heap-size over set-DIDEVICEINSTANCEW-dwSize
    [ IDirectInputDevice8W::GetDeviceInfo ole32-error ] keep
    DIDEVICEINSTANCEW-dwDevType GET_DIDEVICE_TYPE
    DI8DEVTYPE_KEYBOARD DI8DEVTYPE_MOUSE 2array member? not ;

: device-attached? ( guid -- ? )
    +dinput+ get swap IDirectInput8W::GetDeviceStatus
    [ ole32-error ] [ S_OK = ] bi ;

: add-controller ( guid -- )
    [ device-for-guid configure-controller ]
    [ "GUID" heap-size memory>byte-array ] bi
    [ +controller-devices+ get set-at ]
    [ drop com-release ] if ;

: remove-controller ( guid -- )
    "GUID" heap-size memory>byte-array
    +controller-devices+ get [ com-release f ] change-at ;

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
    create-device-change-window
    [ 4dup handle-wm-devicechange DefWindowProc ] WM_DEVICECHANGE add-wm-handler ;

: remove-wm-devicechange ( -- )
    WM_DEVICECHANGE wm-handlers get-global delete-at
    close-device-change-window ;

: release-controllers ( -- )
    +controller-devices+ global [
        [ nip com-release ] assoc-each f
    ] change-at ;

: release-keyboard ( -- )
    +keyboard-device+ global [ com-release f ] change-at ;

M: dinput-game-input-backend open-game-input
    create-dinput
    find-keyboard
    find-controllers ;

M: dinput-game-input-backend close-game-input
    release-controllers
    release-keyboard
    delete-dinput ;

