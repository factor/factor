USING: accessors alien alien.c-types alien.data alien.strings
arrays assocs byte-arrays classes.struct combinators
combinators.short-circuit game.input
game.input.dinput.keys-array kernel math math.bitwise
math.rectangles namespaces sequences specialized-arrays
ui.backend.windows vectors windows.com windows.directx.dinput
windows.directx.dinput.constants windows.errors windows.kernel32
windows.messages windows.ole32 windows.user32 ;
SPECIALIZED-ARRAY: DIDEVICEOBJECTDATA
IN: game.input.dinput

CONSTANT: MOUSE-BUFFER-SIZE 16

SINGLETON: dinput-game-input-backend

dinput-game-input-backend game-input-backend set-global

SYMBOLS: +dinput+ +keyboard-device+ +keyboard-state+
    +controller-devices+ +controller-guids+
    +device-change-window+ +device-change-handle+
    +mouse-device+ +mouse-state+ +mouse-buffer+ ;

: create-dinput ( -- )
    f GetModuleHandle DIRECTINPUT_VERSION IDirectInput8W-iid
    f void* <ref> [ f DirectInput8Create check-ole32-error ] keep void* deref
    +dinput+ set-global ;

: delete-dinput ( -- )
    +dinput+ [ com-release f ] change-global ;

: device-for-guid ( guid -- device )
    +dinput+ get-global swap f void* <ref>
    [ f IDirectInput8W::CreateDevice check-ole32-error ] keep void* deref ;

: set-coop-level ( device -- )
    +device-change-window+ get-global DISCL_BACKGROUND DISCL_NONEXCLUSIVE bitor
    IDirectInputDevice8W::SetCooperativeLevel check-ole32-error ; inline

: set-data-format ( device format-symbol -- )
    get-global IDirectInputDevice8W::SetDataFormat check-ole32-error ; inline

: <buffer-size-diprop> ( size -- DIPROPDWORD )
    DIPROPDWORD new [
        diph>>
        DIPROPDWORD heap-size  >>dwSize
        DIPROPHEADER heap-size >>dwHeaderSize
        0           >>dwObj
        DIPH_DEVICE >>dwHow
        drop
    ] guard >>dwData ;

: set-buffer-size ( device size -- )
    DIPROP_BUFFERSIZE swap <buffer-size-diprop>
    IDirectInputDevice8W::SetProperty check-ole32-error ;

: configure-keyboard ( keyboard -- )
    [ c_dfDIKeyboard_HID set-data-format ] [ set-coop-level ] bi ;
: configure-mouse ( mouse -- )
    [ c_dfDIMouse2 set-data-format ]
    [ MOUSE-BUFFER-SIZE set-buffer-size ]
    [ set-coop-level ] tri ;
: configure-controller ( controller -- )
    [ c_dfDIJoystick2 set-data-format ] [ set-coop-level ] bi ;

: find-keyboard ( -- )
    GUID_SysKeyboard device-for-guid
    [ configure-keyboard ]
    [ +keyboard-device+ set-global ] bi
    256 <byte-array> 256 <keys-array> keyboard-state boa
    +keyboard-state+ set-global ;

: find-mouse ( -- )
    GUID_SysMouse device-for-guid
    [ configure-mouse ] [ +mouse-device+ set-global ] bi
    0 0 0 0 8 f <array> mouse-state boa +mouse-state+ set-global
    MOUSE-BUFFER-SIZE DIDEVICEOBJECTDATA <c-array> +mouse-buffer+ set-global ;

: device-info ( device -- DIDEVICEIMAGEINFOW )
    DIDEVICEINSTANCEW new
        DIDEVICEINSTANCEW heap-size >>dwSize
    [ IDirectInputDevice8W::GetDeviceInfo check-ole32-error ] keep ; inline
: device-caps ( device -- DIDEVCAPS )
    DIDEVCAPS new
        DIDEVCAPS heap-size >>dwSize
    [ IDirectInputDevice8W::GetCapabilities check-ole32-error ] keep ; inline

: device-guid ( device -- guid )
    device-info guidInstance>> ; inline

: device-attached? ( device -- ? )
    +dinput+ get swap device-guid
    IDirectInput8W::GetDeviceStatus S_OK = ;

: (find-device-axes-callback) ( lpddoi pvRef -- BOOL )
    +controller-devices+ get-global at
    swap guidType>> {
        { [ dup GUID_XAxis = ] [ drop 0.0 >>x ] }
        { [ dup GUID_YAxis = ] [ drop 0.0 >>y ] }
        { [ dup GUID_ZAxis = ] [ drop 0.0 >>z ] }
        { [ dup GUID_RxAxis = ] [ drop 0.0 >>rx ] }
        { [ dup GUID_RyAxis = ] [ drop 0.0 >>ry ] }
        { [ dup GUID_RzAxis = ] [ drop 0.0 >>rz ] }
        { [ dup GUID_Slider = ] [ drop 0.0 >>slider ] }
        [ drop ]
    } cond drop
    DIENUM_CONTINUE ;

: find-device-axes-callback ( -- alien )
    [ (find-device-axes-callback) ] LPDIENUMDEVICEOBJECTSCALLBACKW ;

: find-device-axes ( device controller-state -- controller-state )
    swap [ +controller-devices+ get-global set-at ] 2keep
    find-device-axes-callback over DIDFT_AXIS
    IDirectInputDevice8W::EnumObjects check-ole32-error ;

: controller-state-template ( device -- controller-state )
    controller-state new
    over device-caps
    [ dwButtons>> f <array> >>buttons ]
    [ dwPOVs>> zero? f pov-neutral ? >>pov ] bi
    find-device-axes ;

: device-known? ( guid -- ? )
    +controller-guids+ get-global key? ; inline

: (add-controller) ( guid -- )
    device-for-guid {
        [ configure-controller ]
        [ controller-state-template ]
        [ dup device-guid clone +controller-guids+ get-global set-at ]
        [ +controller-devices+ get-global set-at ]
    } cleave ;

: add-controller ( guid -- )
    dup device-known? [ drop ] [ (add-controller) ] if ;

: remove-controller ( device -- )
    [ +controller-devices+ get-global delete-at ]
    [ device-guid +controller-guids+ get-global delete-at ]
    [ com-release ] tri ;

: (find-controller-callback) ( lpddi pvRef -- BOOL )
    drop guidInstance>> add-controller
    DIENUM_CONTINUE ;

: find-controller-callback ( -- alien )
    [ (find-controller-callback) ] LPDIENUMDEVICESCALLBACKW ;

: find-controllers ( -- )
    +dinput+ get-global DI8DEVCLASS_GAMECTRL find-controller-callback
    f DIEDFL_ATTACHEDONLY IDirectInput8W::EnumDevices check-ole32-error ;

: set-up-controllers ( -- )
    4 <vector> +controller-devices+ set-global
    4 <vector> +controller-guids+ set-global
    find-controllers ;

: find-and-remove-detached-devices ( -- )
    +controller-devices+ get-global keys
    [ device-attached? ] reject
    [ remove-controller ] each ;

: ?device-interface ( dbt-broadcast-hdr -- ? )
    dup dbch_devicetype>> DBT_DEVTYP_DEVICEINTERFACE =
    [ >c-ptr DEV_BROADCAST_DEVICEW memory>struct ]
    [ drop f ] if ; inline

: device-arrived ( dbt-broadcast-hdr -- )
    ?device-interface [ find-controllers ] when ; inline

: device-removed ( dbt-broadcast-hdr -- )
    ?device-interface [ find-and-remove-detached-devices ] when ; inline

: <DEV_BROADCAST_HDR> ( wParam -- struct )
    <alien> DEV_BROADCAST_HDR memory>struct ;

: handle-wm-devicechange ( hWnd uMsg wParam lParam -- )
    2nipd swap {
        { [ dup DBT_DEVICEARRIVAL = ]         [ drop <DEV_BROADCAST_HDR> device-arrived ] }
        { [ dup DBT_DEVICEREMOVECOMPLETE = ]  [ drop <DEV_BROADCAST_HDR> device-removed ] }
        [ 2drop ]
    } cond ;

TUPLE: window-rect < rect window-loc ;
: <zero-window-rect> ( -- window-rect )
    window-rect new
    { 0 0 } >>window-loc
    { 0 0 } >>loc
    { 0 0 } >>dim ;

: (device-notification-filter) ( -- DEV_BROADCAST_DEVICEW )
    DEV_BROADCAST_DEVICEW new
        DEV_BROADCAST_DEVICEW heap-size >>dbcc_size
        DBT_DEVTYP_DEVICEINTERFACE >>dbcc_devicetype ;

: create-device-change-window ( -- )
    <zero-window-rect> WS_OVERLAPPEDWINDOW 0 create-window
    [
        (device-notification-filter)
        DEVICE_NOTIFY_WINDOW_HANDLE DEVICE_NOTIFY_ALL_INTERFACE_CLASSES bitor
        RegisterDeviceNotification
        +device-change-handle+ set-global
    ]
    [ +device-change-window+ set-global ] bi ;

: close-device-change-window ( -- )
    +device-change-handle+ [ UnregisterDeviceNotification drop f ] change-global
    +device-change-window+ [ DestroyWindow win32-error=0/f f ] change-global ;

: add-wm-devicechange ( -- )
    [ 4dup handle-wm-devicechange DefWindowProc ]
    WM_DEVICECHANGE add-wm-handler ;

: remove-wm-devicechange ( -- )
    WM_DEVICECHANGE wm-handlers get-global delete-at ;

: release-controllers ( -- )
    +controller-devices+ [ [ drop com-release ] assoc-each f ] change-global
    f +controller-guids+ set-global ;

: release-keyboard ( -- )
    +keyboard-device+ [ com-release f ] change-global
    f +keyboard-state+ set-global ;

: release-mouse ( -- )
    +mouse-device+ [ com-release f ] change-global
    f +mouse-state+ set-global ;

M: dinput-game-input-backend (open-game-input)
    create-dinput
    create-device-change-window
    find-keyboard
    find-mouse
    set-up-controllers
    add-wm-devicechange ;

M: dinput-game-input-backend (close-game-input)
    remove-wm-devicechange
    release-controllers
    release-mouse
    release-keyboard
    close-device-change-window
    delete-dinput ;

M: dinput-game-input-backend (reset-game-input)
    [
        {
            +dinput+ +keyboard-device+ +keyboard-state+
            +controller-devices+ +controller-guids+
            +device-change-window+ +device-change-handle+
        } [ off ] each
    ] with-global ;

M: dinput-game-input-backend get-controllers
    +controller-devices+ get-global
    [ drop controller boa ] { } assoc>map ;

M: dinput-game-input-backend product-string
    handle>> device-info tszProductName>>
    alien>native-string ;

M: dinput-game-input-backend product-id
    handle>> device-info guidProduct>> ;
M: dinput-game-input-backend instance-id
    handle>> device-guid ;

:: with-acquisition ( device acquired-quot succeeded-quot failed-quot -- result/f )
    device { [ ] [ IDirectInputDevice8W::Acquire succeeded? ] } 1&& [
        device acquired-quot call
        succeeded-quot call
    ] failed-quot if ; inline

CONSTANT: pov-values
    {
        pov-up pov-up-right pov-right pov-down-right
        pov-down pov-down-left pov-left pov-up-left
    }

: >axis ( long -- float )
    32767 - 32767.0 /f ; inline
: >slider ( long -- float )
    65535.0 /f ; inline
: >pov ( long -- symbol )
    dup 0xFFFF bitand 0xFFFF =
    [ drop pov-neutral ]
    [ 2750 + 4500 /i pov-values nth ] if ; inline

: (fill-if) ( controller-state DIJOYSTATE2 ? quot -- )
    [ drop ] compose [ 2drop ] if ; inline

: fill-controller-state ( controller-state DIJOYSTATE2 -- controller-state )
    {
        [ over x>> [ lX>> >axis >>x ] (fill-if) ]
        [ over y>> [ lY>> >axis >>y ] (fill-if) ]
        [ over z>> [ lZ>> >axis >>z ] (fill-if) ]
        [ over rx>> [ lRx>> >axis >>rx ] (fill-if) ]
        [ over ry>> [ lRy>> >axis >>ry ] (fill-if) ]
        [ over rz>> [ lRz>> >axis >>rz ] (fill-if) ]
        [ over slider>> [ rglSlider>> first >slider >>slider ] (fill-if) ]
        [ over pov>> [ rgdwPOV>> first >pov >>pov ] (fill-if) ]
        [ rgbButtons>> over buttons>> length <keys-array> >>buttons ]
    } 2cleave ;

: read-device-buffer ( device buffer count -- buffer count' )
    [ DIDEVICEOBJECTDATA heap-size ] 2dip uint <ref>
    [ 0 IDirectInputDevice8W::GetDeviceData check-ole32-error ] 2keep uint deref ;

: (fill-mouse-state) ( state DIDEVICEOBJECTDATA -- state )
    [ dwData>> 32 >signed ] [ dwOfs>> ] bi {
        { DIMOFS_X [ [ + ] curry change-dx ] }
        { DIMOFS_Y [ [ + ] curry change-dy ] }
        { DIMOFS_Z [ [ + ] curry change-scroll-dy ] }
        [ [ c-bool> ] [ DIMOFS_BUTTON0 - ] bi* rot [ buttons>> set-nth ] keep ]
    } case ;

: fill-mouse-state ( buffer count -- state )
    <iota> [ +mouse-state+ get-global ] 2dip swap [ nth (fill-mouse-state) ] curry each ;

: get-device-state ( device DIJOYSTATE2 -- )
    [ dup IDirectInputDevice8W::Poll check-ole32-error ] dip
    [ byte-length ] keep
    IDirectInputDevice8W::GetDeviceState check-ole32-error ;

: (read-controller) ( handle template -- state )
    swap [ DIJOYSTATE2 new [ get-device-state ] keep ]
    [ fill-controller-state ] [ drop f ] with-acquisition ;

M: dinput-game-input-backend read-controller
    handle>> dup +controller-devices+ get-global at
    [ (read-controller) ] [ drop f ] if* ;

M: dinput-game-input-backend calibrate-controller
    handle>> f 0 IDirectInputDevice8W::RunControlPanel check-ole32-error ;

M: dinput-game-input-backend read-keyboard
    +keyboard-device+ get-global
    [ +keyboard-state+ get-global [ keys>> underlying>> get-device-state ] keep ]
    [ ] [ f ] with-acquisition ;

M: dinput-game-input-backend read-mouse
    +mouse-device+ get-global [ +mouse-buffer+ get-global MOUSE-BUFFER-SIZE read-device-buffer ]
    [ fill-mouse-state ] [ f ] with-acquisition ;

M: dinput-game-input-backend reset-mouse
    +mouse-device+ get-global [ f MOUSE-BUFFER-SIZE read-device-buffer ]
    [ 2drop ] [ ] with-acquisition
    +mouse-state+ get-global
        0 >>dx
        0 >>dy
        0 >>scroll-dx
        0 >>scroll-dy
        drop ;
