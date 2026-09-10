! Copyright (C) 2010, 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums arrays assocs classes.mixin continuations
destructors game.input init io.encodings.binary io.files kernel libc linux.input-events
linux.input-events.ffi literals locals math math.functions math.order namespaces
sequences sets sorting unix unix.ffi ;
IN: game.input.linux

MIXIN: linux-game-input-backend

! Retain the owning stream, not just its fd. Repeated enumeration reuses
! these handles, and closing game input releases them exactly once.
TUPLE: linux-controller < controller path meta fd buttons axes ;
TUPLE: linux-controller-state < controller-state abs ;

SYMBOL: linux-controllers
linux-controllers [ H{ } clone ] initialize
STARTUP-HOOK: [ H{ } clone linux-controllers set-global ]

:: <linux-controller> ( path -- controller )
    path get-event-device-info :> meta
    [
        path binary <file-reader> |dispose :> stream
        linux-controller new path >>path meta >>meta stream >>handle
            stream handle>> fd>> >>fd
            meta "capabilities" of EV_KEY of keys >>buttons
            meta "capabilities" of EV_ABS of keys [ first ] map >>axes
    ] with-destructors ;

M: linux-controller dispose
    [ handle>> [ dispose ] when* ] [ f >>handle f >>fd drop ] bi ;

: close-linux-controllers ( -- )
    linux-controllers get-global [ values dispose-each ] [ clear-assoc ] bi ;

: controller-paths ( -- paths )
    "/dev/input/by-id" file-exists?
    [ get-input-events-joysticks values members natural-sort ] [ { } ] if ;

: unavailable-controller? ( error -- ? )
    dup unix-system-call-error? [
        errno>> ${ ENOENT ENODEV EACCES EPERM } member?
    ] [ drop f ] if ;

M:: linux-game-input-backend get-controllers ( -- controllers )
    controller-paths :> paths
    linux-controllers get-global :> registry
    registry keys [| path |
        path paths member? [ path registry delete-at* drop dispose ] unless
    ] each
    paths [| path |
        path registry at [ fd>> not ] [ f ] if*
        [ path registry delete-at ] when
        [ path registry [ <linux-controller> ] cache ] [
            dup unavailable-controller? [ drop f ] [ rethrow ] if
        ] recover
    ] map sift ;

M: linux-game-input-backend product-string meta>> "name" of ;
M: linux-game-input-backend product-id meta>> "id" of ;
M: linux-game-input-backend instance-id path>> ;

:: axis-fraction ( info -- value )
    info maximum>> info minimum>> - :> span
    span 0 > [ info value>> info minimum>> - span /f 0.0 1.0 clamp ] [ 0.0 ] if ;

:: normalized-axis ( info -- value )
    info maximum>> info minimum>> + 2 / :> center
    info value>> center - abs info flat>> <=
    info maximum>> info minimum>> <= or
    [ 0.0 ] [ info axis-fraction 2.0 * 1.0 - ] if ;

: axis-value ( axes code -- value/f )
    enum>number swap at [ normalized-axis ] [ f ] if* ;

: hat-value ( axes code -- value )
    enum>number swap at [ value>> sgn ] [ 0 ] if* ;

:: axes>pov ( axes -- pov/f )
    ABS_HAT0X enum>number axes key? ABS_HAT0Y enum>number axes key? or [
        axes ABS_HAT0X hat-value axes ABS_HAT0Y hat-value 2array {
            { { -1 -1 } pov-up-left } { { 0 -1 } pov-up } { { 1 -1 } pov-up-right }
            { { -1 0 } pov-left } { { 0 0 } pov-neutral } { { 1 0 } pov-right }
            { { -1 1 } pov-down-left } { { 0 1 } pov-down } { { 1 1 } pov-down-right }
        } at
    ] [ f ] if ;

:: controller-snapshot ( axes supported-buttons pressed-buttons -- state )
    linux-controller-state new axes >>abs
        axes ABS_X axis-value >>x axes ABS_Y axis-value >>y axes ABS_Z axis-value >>z
        axes ABS_RX axis-value >>rx axes ABS_RY axis-value >>ry axes ABS_RZ axis-value >>rz
        ABS_THROTTLE enum>number axes at [ axis-fraction ] [ f ] if* >>slider
        axes axes>pov >>pov
        supported-buttons [ pressed-buttons member? 1.0 f ? ] map >>buttons ;

:: read-linux-controller ( controller -- state )
    controller axes>> [| code |
        code controller fd>> code evdev-get-abs 2array
    ] map
    controller buttons>> controller fd>> evdev-get-key seq>explode-positions
    controller-snapshot ;

M:: linux-game-input-backend read-controller ( controller -- state/f )
    controller fd>> [
        [ controller read-linux-controller ] [
            dup unix-system-call-error? [ dup errno>> ENODEV = ] [ f ] if
            [ drop controller dispose f ] [ rethrow ] if
        ] recover
    ] [ f ] if ;

M: linux-game-input-backend calibrate-controller drop ;
M: linux-game-input-backend vibrate-controller 3drop ;
