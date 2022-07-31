USING: accessors alien alien.c-types arrays assocs bit-arrays
cocoa.application cocoa.enumeration cocoa.plists combinators
combinators.short-circuit core-foundation core-foundation.data
core-foundation.run-loop core-foundation.strings destructors
game.input hints iokit iokit.hid kernel math namespaces
sequences vectors ;
IN: game.input.iokit

SINGLETON: iokit-game-input-backend

SYMBOLS: +hid-manager+ +keyboard-state+ +mouse-state+ +controller-states+ ;

iokit-game-input-backend game-input-backend set-global

: make-hid-manager ( -- alien )
    f 0 IOHIDManagerCreate ;

: set-hid-manager-matching ( alien matching-seq -- )
    >plist IOHIDManagerSetDeviceMatchingMultiple ;

: devices-from-hid-manager ( manager -- vector )
    [
        IOHIDManagerCopyDevices
        [ &CFRelease NSFastEnumeration>vector ] [ f ] if*
    ] with-destructors ;

CONSTANT: game-devices-matching-seq
    {
        H{ { "DeviceUsage" 2 } { "DeviceUsagePage" 1 } } ! mouses
        H{ { "DeviceUsage" 4 } { "DeviceUsagePage" 1 } } ! joysticks
        H{ { "DeviceUsage" 5 } { "DeviceUsagePage" 1 } } ! gamepads
        H{ { "DeviceUsage" 6 } { "DeviceUsagePage" 1 } } ! keyboards
        H{ { "DeviceUsage" 7 } { "DeviceUsagePage" 1 } } ! keypads
        H{ { "DeviceUsage" 8 } { "DeviceUsagePage" 1 } } ! multiaxis controllers
    }

CONSTANT: buttons-matching-hash
    H{ { "UsagePage" 9 } { "Type" 2 } }
CONSTANT: keys-matching-hash
    H{ { "UsagePage" 7 } { "Type" 2 } }
CONSTANT: x-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x30 } { "Type" 1 } }
CONSTANT: y-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x31 } { "Type" 1 } }
CONSTANT: z-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x32 } { "Type" 1 } }
CONSTANT: rx-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x33 } { "Type" 1 } }
CONSTANT: ry-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x34 } { "Type" 1 } }
CONSTANT: rz-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x35 } { "Type" 1 } }
CONSTANT: slider-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x36 } { "Type" 1 } }
CONSTANT: wheel-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x38 } { "Type" 1 } }
CONSTANT: hat-switch-matching-hash
    H{ { "UsagePage" 1 } { "Usage" 0x39 } { "Type" 1 } }

: device-elements-matching ( device matching-hash -- vector )
    [
        >plist 0 IOHIDDeviceCopyMatchingElements
        [ &CFRelease NSFastEnumeration>vector ] [ f ] if*
    ] with-destructors ;

: button-count ( device -- button-count )
    buttons-matching-hash device-elements-matching length ;

: ?axis ( device hash -- axis/f )
    device-elements-matching ?first ;

: ?x-axis ( device -- ? )
    x-axis-matching-hash ?axis ;
: ?y-axis ( device -- ? )
    y-axis-matching-hash ?axis ;
: ?z-axis ( device -- ? )
    z-axis-matching-hash ?axis ;
: ?rx-axis ( device -- ? )
    rx-axis-matching-hash ?axis ;
: ?ry-axis ( device -- ? )
    ry-axis-matching-hash ?axis ;
: ?rz-axis ( device -- ? )
    rz-axis-matching-hash ?axis ;
: ?slider ( device -- ? )
    slider-matching-hash ?axis ;
: ?hat-switch ( device -- ? )
    hat-switch-matching-hash ?axis ;

: device-property ( device key -- value )
    <NSString> IOHIDDeviceGetProperty [ plist> ] [ f ] if* ;
: element-property ( element key -- value )
    <NSString> IOHIDElementGetProperty [ plist> ] [ f ] if* ;
: set-element-property ( element key value -- )
    [ <NSString> ] [ >plist ] bi* IOHIDElementSetProperty drop ;
: transfer-element-property ( element from-key to-key -- )
    [ dupd element-property ] dip swap
    [ set-element-property ] [ 2drop ] if* ;

: mouse-device? ( device -- ? )
    1 2 IOHIDDeviceConformsTo ;

: controller-device? ( device -- ? )
    {
        [ 1 4 IOHIDDeviceConformsTo ]
        [ 1 5 IOHIDDeviceConformsTo ]
        [ 1 8 IOHIDDeviceConformsTo ]
    } 1|| ;

: element-usage ( element -- {usage-page,usage} )
    [ IOHIDElementGetUsagePage ] [ IOHIDElementGetUsage ] bi
    2array ;

: button? ( element -- ? )
    IOHIDElementGetUsagePage 9 = ; inline
: keyboard-key? ( element -- ? )
    IOHIDElementGetUsagePage 7 = ; inline
: axis? ( element -- ? )
    IOHIDElementGetUsagePage 1 = ; inline

: x-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x30 = ; inline
: y-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x31 = ; inline
: z-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x32 = ; inline
: rx-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x33 = ; inline
: ry-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x34 = ; inline
: rz-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x35 = ; inline
: slider? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x36 = ; inline
: wheel? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x38 = ; inline
: hat-switch? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage 0x39 = ; inline

CONSTANT: pov-values
    {
        pov-up pov-up-right pov-right pov-down-right
        pov-down pov-down-left pov-left pov-up-left
        pov-neutral
    }

: button-value ( value -- f/(0,1] )
    IOHIDValueGetIntegerValue dup zero? [ drop f ] when ;
: axis-value ( value -- [-1,1] )
    kIOHIDValueScaleTypeCalibrated IOHIDValueGetScaledValue ;
: mouse-axis-value ( value -- n )
    IOHIDValueGetIntegerValue ;
: pov-value ( value -- pov-direction )
    IOHIDValueGetIntegerValue pov-values ?nth [ pov-neutral ] unless* ;

: record-button ( state hid-value element -- )
    [ buttons>> ] [ button-value ] [ IOHIDElementGetUsage 1 - ] tri* rot set-nth ;

: record-controller ( controller-state value -- )
    dup IOHIDValueGetElement {
        { [ dup button? ] [ record-button ] }
        { [ dup axis? ] [ {
            { [ dup x-axis? ] [ drop axis-value >>x drop ] }
            { [ dup y-axis? ] [ drop axis-value >>y drop ] }
            { [ dup z-axis? ] [ drop axis-value >>z drop ] }
            { [ dup rx-axis? ] [ drop axis-value >>rx drop ] }
            { [ dup ry-axis? ] [ drop axis-value >>ry drop ] }
            { [ dup rz-axis? ] [ drop axis-value >>rz drop ] }
            { [ dup slider? ] [ drop axis-value >>slider drop ] }
            { [ dup hat-switch? ] [ drop pov-value >>pov drop ] }
            [ 3drop ]
        } cond ] }
        [ 3drop ]
    } cond ;

HINTS: record-controller { controller-state alien } ;

: record-keyboard ( keyboard-state value -- )
    dup IOHIDValueGetElement dup keyboard-key? [
        [ IOHIDValueGetIntegerValue c-bool> ]
        [ IOHIDElementGetUsage ] bi*
        rot ?set-nth
    ] [ 3drop ] if ;

HINTS: record-keyboard { bit-array alien } ;

: record-mouse ( mouse-state value -- )
    dup IOHIDValueGetElement {
        { [ dup button? ] [ record-button ] }
        { [ dup axis? ] [ {
            { [ dup x-axis? ] [ drop mouse-axis-value [ + ] curry change-dx drop ] }
            { [ dup y-axis? ] [ drop mouse-axis-value [ + ] curry change-dy drop ] }
            { [ dup wheel?  ] [ drop mouse-axis-value [ + ] curry change-scroll-dx drop ] }
            { [ dup z-axis? ] [ drop mouse-axis-value [ + ] curry change-scroll-dy drop ] }
            [ 3drop ]
        } cond ] }
        [ 3drop ]
    } cond ;

HINTS: record-mouse { mouse-state alien } ;

M: iokit-game-input-backend read-mouse
    +mouse-state+ get-global ;

M: iokit-game-input-backend reset-mouse
    +mouse-state+ get-global
        0 >>dx
        0 >>dy
        0 >>scroll-dx
        0 >>scroll-dy
        drop ;

: default-calibrate-saturation ( element -- )
    [ kIOHIDElementMinKey kIOHIDElementCalibrationSaturationMinKey transfer-element-property ]
    [ kIOHIDElementMaxKey kIOHIDElementCalibrationSaturationMaxKey transfer-element-property ]
    bi ;

: default-calibrate-axis ( element -- )
    [ kIOHIDElementCalibrationMinKey -1.0 set-element-property ]
    [ kIOHIDElementCalibrationMaxKey 1.0 set-element-property ]
    [ default-calibrate-saturation ]
    tri ;

: default-calibrate-slider ( element -- )
    [ kIOHIDElementCalibrationMinKey 0.0 set-element-property ]
    [ kIOHIDElementCalibrationMaxKey 1.0 set-element-property ]
    [ default-calibrate-saturation ]
    tri ;

: (default) ( ? quot -- )
    [ f ] if* ; inline

: <device-controller-state> ( device -- controller-state )
    {
        [ ?x-axis [ default-calibrate-axis 0.0 ] (default) ]
        [ ?y-axis [ default-calibrate-axis 0.0 ] (default) ]
        [ ?z-axis [ default-calibrate-axis 0.0 ] (default) ]
        [ ?rx-axis [ default-calibrate-axis 0.0 ] (default) ]
        [ ?ry-axis [ default-calibrate-axis 0.0 ] (default) ]
        [ ?rz-axis [ default-calibrate-axis 0.0 ] (default) ]
        [ ?slider [ default-calibrate-slider 0.0 ] (default) ]
        [ ?hat-switch pov-neutral and ]
        [ button-count f <array> ]
    } cleave controller-state boa ;

: ?add-mouse-buttons ( device -- )
    button-count +mouse-state+ get-global buttons>>
    2dup length >
    [ set-length ] [ 2drop ] if ;

:: (device-matched-callback) ( context result sender device -- )
    {
        { [ device mouse-device? ] [ device ?add-mouse-buttons ] }
        { [ device controller-device? ] [
            device <device-controller-state>
            device +controller-states+ get-global set-at
        ] }
        [ ]
    } cond ;

: device-matched-callback ( -- alien )
    [ (device-matched-callback) ] IOHIDDeviceCallback ;

:: (device-removed-callback) ( context result sender device -- )
    device +controller-states+ get-global delete-at ;

: device-removed-callback ( -- alien )
    [ (device-removed-callback) ] IOHIDDeviceCallback ;

! Lion sends the input callback an IOHIDQueue as the "sender".
! Leopard and Snow Leopard send an IOHIDDevice.
! This function gets the IOHIDDevice regardless of which is received
: get-input-device ( sender -- device )
    dup CFGetTypeID {
        { [ dup IOHIDDeviceGetTypeID = ] [ drop ] }
        { [ dup IOHIDQueueGetTypeID = ] [ drop IOHIDQueueGetDevice ] }
        [
            drop
            "input callback doesn't know how to deal with "
            swap CF>description append throw
        ]
    } cond ;

:: (device-input-callback) ( context result sender value -- )
    sender get-input-device :> device
    {
        { [ device mouse-device? ] [ +mouse-state+ get-global value record-mouse ] }
        { [ device controller-device? ] [
            device +controller-states+ get-global at value record-controller
        ] }
        [ +keyboard-state+ get-global value record-keyboard ]
    } cond ;

: device-input-callback ( -- alien )
    [ (device-input-callback) ] IOHIDValueCallback ;

: initialize-variables ( manager -- )
    +hid-manager+ set-global
    4 <vector> +controller-states+ set-global
    0 0 0 0 2 <vector> mouse-state boa
        +mouse-state+ set-global
    256 <bit-array> +keyboard-state+ set-global ;

M: iokit-game-input-backend (open-game-input)
    make-hid-manager {
        [ initialize-variables ]
        [ device-matched-callback f IOHIDManagerRegisterDeviceMatchingCallback ]
        [ device-removed-callback f IOHIDManagerRegisterDeviceRemovalCallback ]
        [ device-input-callback f IOHIDManagerRegisterInputValueCallback ]
        [ 0 IOHIDManagerOpen mach-error ]
        [ game-devices-matching-seq set-hid-manager-matching ]
        [
            CFRunLoopGetMain CFRunLoopDefaultMode
            IOHIDManagerScheduleWithRunLoop
        ]
    } cleave ;

M: iokit-game-input-backend (reset-game-input)
    { +hid-manager+ +keyboard-state+ +mouse-state+ +controller-states+ }
    [ f swap set-global ] each ;

M: iokit-game-input-backend (close-game-input)
    +hid-manager+ get-global [
        +hid-manager+ [
            [
                CFRunLoopGetMain CFRunLoopDefaultMode
                IOHIDManagerUnscheduleFromRunLoop
            ]
            [ 0 IOHIDManagerClose drop ]
            [ CFRelease ] tri
            f
        ] change-global
        f +keyboard-state+ set-global
        f +mouse-state+ set-global
        f +controller-states+ set-global
    ] when ;

M: iokit-game-input-backend get-controllers
    +controller-states+ get-global keys [ controller boa ] map ;

: ?glue ( seq subseq sep -- string )
    2over subseq-index [ drop nip ] [ glue ] if ;

M: iokit-game-input-backend product-string
    handle>>
    [ kIOHIDProductKey      device-property ]
    [ kIOHIDManufacturerKey device-property ] bi " " ?glue ;

M: iokit-game-input-backend product-id
    handle>>
    [ kIOHIDVendorIDKey  device-property ]
    [ kIOHIDProductIDKey device-property ] bi 2array ;

M: iokit-game-input-backend instance-id
    handle>> kIOHIDLocationIDKey device-property ;

M: iokit-game-input-backend read-controller
    handle>> +controller-states+ get-global at clone ;

M: iokit-game-input-backend read-keyboard
    +keyboard-state+ get-global clone keyboard-state boa ;

M: iokit-game-input-backend calibrate-controller
    drop ;
