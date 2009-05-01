USING: cocoa cocoa.plists core-foundation iokit iokit.hid
kernel cocoa.enumeration destructors math.parser cocoa.application 
sequences locals combinators.short-circuit threads
namespaces assocs vectors arrays combinators
core-foundation.run-loop accessors sequences.private
alien.c-types math parser game-input ;
IN: game-input.iokit

SINGLETON: iokit-game-input-backend

iokit-game-input-backend game-input-backend set-global

: hid-manager-matching ( matching-seq -- alien )
    f 0 IOHIDManagerCreate
    [ swap >plist IOHIDManagerSetDeviceMatchingMultiple ]
    keep ;

: devices-from-hid-manager ( manager -- vector )
    [
        IOHIDManagerCopyDevices
        [ &CFRelease NSFastEnumeration>vector ] [ f ] if*
    ] with-destructors ;

CONSTANT: game-devices-matching-seq
    {
        H{ { "DeviceUsage" 4 } { "DeviceUsagePage" 1 } } ! joysticks
        H{ { "DeviceUsage" 5 } { "DeviceUsagePage" 1 } } ! gamepads
        H{ { "DeviceUsage" 6 } { "DeviceUsagePage" 1 } } ! keyboards
    }

CONSTANT: buttons-matching-hash
    H{ { "UsagePage" 9 } { "Type" 2 } }
CONSTANT: keys-matching-hash
    H{ { "UsagePage" 7 } { "Type" 2 } }
CONSTANT: x-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 30 } { "Type" 1 } }
CONSTANT: y-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 31 } { "Type" 1 } }
CONSTANT: z-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 32 } { "Type" 1 } }
CONSTANT: rx-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 33 } { "Type" 1 } }
CONSTANT: ry-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 34 } { "Type" 1 } }
CONSTANT: rz-axis-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 35 } { "Type" 1 } }
CONSTANT: slider-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 36 } { "Type" 1 } }
CONSTANT: hat-switch-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 39 } { "Type" 1 } }

: device-elements-matching ( device matching-hash -- vector )
    [
        >plist 0 IOHIDDeviceCopyMatchingElements
        [ &CFRelease NSFastEnumeration>vector ] [ f ] if*
    ] with-destructors ;

: button-count ( device -- button-count )
    buttons-matching-hash device-elements-matching length ;

: ?axis ( device hash -- axis/f )
    device-elements-matching [ f ] [ first ] if-empty ;

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

: hid-manager-matching-game-devices ( -- alien )
    game-devices-matching-seq hid-manager-matching ;

: device-property ( device key -- value )
    <NSString> IOHIDDeviceGetProperty plist> ;
: element-property ( element key -- value )
    <NSString> IOHIDElementGetProperty plist> ;
: set-element-property ( element key value -- )
    [ <NSString> ] [ >plist ] bi* IOHIDElementSetProperty drop ;
: transfer-element-property ( element from-key to-key -- )
    [ dupd element-property ] dip swap set-element-property ;

: controller-device? ( device -- ? )
    {
        [ 1 4 IOHIDDeviceConformsTo ]
        [ 1 5 IOHIDDeviceConformsTo ]
    } 1|| ;

: element-usage ( element -- {usage-page,usage} )
    [ IOHIDElementGetUsagePage ] [ IOHIDElementGetUsage ] bi
    2array ;

: button? ( {usage-page,usage} -- ? )
    first 9 = ; inline
: keyboard-key? ( {usage-page,usage} -- ? )
    first 7 = ; inline
: x-axis? ( {usage-page,usage} -- ? )
    { 1 HEX: 30 } = ; inline
: y-axis? ( {usage-page,usage} -- ? )
    { 1 HEX: 31 } = ; inline
: z-axis? ( {usage-page,usage} -- ? )
    { 1 HEX: 32 } = ; inline
: rx-axis? ( {usage-page,usage} -- ? )
    { 1 HEX: 33 } = ; inline
: ry-axis? ( {usage-page,usage} -- ? )
    { 1 HEX: 34 } = ; inline
: rz-axis? ( {usage-page,usage} -- ? )
    { 1 HEX: 35 } = ; inline
: slider? ( {usage-page,usage} -- ? )
    { 1 HEX: 36 } = ; inline
: hat-switch? ( {usage-page,usage} -- ? )
    { 1 HEX: 39 } = ; inline

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
: pov-value ( value -- pov-direction )
    IOHIDValueGetIntegerValue pov-values ?nth [ pov-neutral ] unless* ;

: record-controller ( controller-state value -- )
    dup IOHIDValueGetElement element-usage {
        { [ dup button? ] [ [ button-value ] [ second 1- ] bi* rot buttons>> set-nth ] } 
        { [ dup x-axis? ] [ drop axis-value >>x drop ] }
        { [ dup y-axis? ] [ drop axis-value >>y drop ] }
        { [ dup z-axis? ] [ drop axis-value >>z drop ] }
        { [ dup rx-axis? ] [ drop axis-value >>rx drop ] }
        { [ dup ry-axis? ] [ drop axis-value >>ry drop ] }
        { [ dup rz-axis? ] [ drop axis-value >>rz drop ] }
        { [ dup slider? ] [ drop axis-value >>slider drop ] }
        { [ dup hat-switch? ] [ drop pov-value >>pov drop ] }
        [ 3drop ]
    } cond ;

SYMBOLS: +hid-manager+ +keyboard-state+ +controller-states+ ;

: ?set-nth ( value nth seq -- )
    2dup bounds-check? [ set-nth-unsafe ] [ 3drop ] if ;

: record-keyboard ( value -- )
    dup IOHIDValueGetElement element-usage keyboard-key? [
        [ IOHIDValueGetIntegerValue c-bool> ]
        [ IOHIDValueGetElement IOHIDElementGetUsage ] bi
        +keyboard-state+ get ?set-nth
    ] [ drop ] if ;

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

: device-matched-callback ( -- alien )
    [| context result sender device |
        device controller-device? [
            device <device-controller-state>
            device +controller-states+ get set-at
        ] when
    ] IOHIDDeviceCallback ;

: device-removed-callback ( -- alien )
    [| context result sender device |
        device +controller-states+ get delete-at
    ] IOHIDDeviceCallback ;

: device-input-callback ( -- alien )
    [| context result sender value |
        sender controller-device?
        [ sender +controller-states+ get at value record-controller ]
        [ value record-keyboard ]
        if
    ] IOHIDValueCallback ;

: initialize-variables ( manager -- )
    +hid-manager+ set-global
    4 <vector> +controller-states+ set-global
    256 f <array> +keyboard-state+ set-global ;

M: iokit-game-input-backend (open-game-input)
    hid-manager-matching-game-devices {
        [ initialize-variables ]
        [ device-matched-callback f IOHIDManagerRegisterDeviceMatchingCallback ]
        [ device-removed-callback f IOHIDManagerRegisterDeviceRemovalCallback ]
        [ device-input-callback f IOHIDManagerRegisterInputValueCallback ]
        [ 0 IOHIDManagerOpen mach-error ]
        [
            CFRunLoopGetMain CFRunLoopDefaultMode
            IOHIDManagerScheduleWithRunLoop
        ]
    } cleave ;

M: iokit-game-input-backend (reset-game-input)
    { +hid-manager+ +keyboard-state+ +controller-states+ }
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
        f +controller-states+ set-global
    ] when ;

M: iokit-game-input-backend get-controllers ( -- sequence )
    +controller-states+ get keys [ controller boa ] map ;

: ?join ( pre post sep -- string )
    2over start [ swap 2nip ] [ [ 2array ] dip join ] if ;

M: iokit-game-input-backend product-string ( controller -- string )
    handle>>
    [ kIOHIDManufacturerKey device-property ]
    [ kIOHIDProductKey      device-property ] bi " " ?join ;
M: iokit-game-input-backend product-id ( controller -- integer )
    handle>>
    [ kIOHIDVendorIDKey  device-property ]
    [ kIOHIDProductIDKey device-property ] bi 2array ;
M: iokit-game-input-backend instance-id ( controller -- integer )
    handle>> kIOHIDLocationIDKey device-property ;

M: iokit-game-input-backend read-controller ( controller -- controller-state )
    handle>> +controller-states+ get at clone ;

M: iokit-game-input-backend read-keyboard ( -- keyboard-state )
    +keyboard-state+ get clone keyboard-state boa ;

M: iokit-game-input-backend calibrate-controller ( controller -- )
    drop ;
