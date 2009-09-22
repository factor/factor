USING: cocoa cocoa.plists core-foundation iokit iokit.hid
kernel cocoa.enumeration destructors math.parser cocoa.application 
sequences locals combinators.short-circuit threads
namespaces assocs arrays combinators hints alien
core-foundation.run-loop accessors sequences.private
alien.c-types alien.data math parser game-input vectors
bit-arrays ;
IN: game-input.iokit

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
CONSTANT: wheel-matching-hash
    H{ { "UsagePage" 1 } { "Usage" HEX: 38 } { "Type" 1 } }
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
    IOHIDElementGetUsage HEX: 30 = ; inline
: y-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 31 = ; inline
: z-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 32 = ; inline
: rx-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 33 = ; inline
: ry-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 34 = ; inline
: rz-axis? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 35 = ; inline
: slider? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 36 = ; inline
: wheel? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 38 = ; inline
: hat-switch? ( {usage-page,usage} -- ? )
    IOHIDElementGetUsage HEX: 39 = ; inline

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

: ?set-nth ( value nth seq -- )
    2dup bounds-check? [ set-nth-unsafe ] [ 3drop ] if ;

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
    +mouse-state+ get ;

M: iokit-game-input-backend reset-mouse
    +mouse-state+ get
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
    button-count +mouse-state+ get buttons>> 
    2dup length >
    [ set-length ] [ 2drop ] if ;

: device-matched-callback ( -- alien )
    [| context result sender device |
        {
            { [ device controller-device? ] [
                device <device-controller-state>
                device +controller-states+ get set-at
            ] }
            { [ device mouse-device? ] [ device ?add-mouse-buttons ] }
            [ ]
        } cond
    ] IOHIDDeviceCallback ;

: device-removed-callback ( -- alien )
    [| context result sender device |
        device +controller-states+ get delete-at
    ] IOHIDDeviceCallback ;

: device-input-callback ( -- alien )
    [| context result sender value |
        {
            { [ sender controller-device? ] [
                sender +controller-states+ get at value record-controller
            ] }
            { [ sender mouse-device? ] [ +mouse-state+ get value record-mouse ] }
            [ +keyboard-state+ get value record-keyboard ]
        } cond
    ] IOHIDValueCallback ;

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
