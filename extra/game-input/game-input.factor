USING: arrays accessors continuations kernel symbols ;
IN: game-input

SYMBOL: game-input-backend

HOOK: open-game-input game-input-backend ( -- )
HOOK: close-game-input game-input-backend ( -- )

: with-game-input ( quot -- )
    open-game-input [ close-game-input ] [ ] cleanup ;

TUPLE: controller handle ;
TUPLE: controller-state x y z rx ry rz slider pov buttons ;

M: controller-state clone
    call-next-method dup buttons>> clone >>buttons ;

SYMBOLS:
    pov-neutral
    pov-up pov-up-left pov-left pov-down-left
    pov-down pov-down-right pov-right pov-up-right ;

HOOK: get-controllers game-input-backend ( -- sequence )

HOOK: manufacturer game-input-backend ( controller -- string )
HOOK: product game-input-backend ( controller -- string )
HOOK: vendor-id game-input-backend ( controller -- integer )
HOOK: product-id game-input-backend ( controller -- integer )
HOOK: location-id game-input-backend ( controller -- integer )

HOOK: read-controller game-input-backend ( controller -- controller-state )
HOOK: calibrate-controller game-input-backend ( controller -- )

TUPLE: keyboard-state keys ;

M: keyboard-state clone
    call-next-method dup keys>> clone >>keys ;

HOOK: read-keyboard game-input-backend ( -- keyboard-state )
