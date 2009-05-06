USING: arrays accessors continuations kernel system
sequences namespaces init vocabs vocabs.loader combinators ;
IN: game-input

SYMBOLS: game-input-backend game-input-opened ;

HOOK: (open-game-input)  game-input-backend ( -- )
HOOK: (close-game-input) game-input-backend ( -- )
HOOK: (reset-game-input) game-input-backend ( -- )

: game-input-opened? ( -- ? )
    game-input-opened get ;

<PRIVATE

M: f (reset-game-input) ;

: reset-game-input ( -- )
    game-input-opened off
    (reset-game-input) ;

[ reset-game-input ] "game-input" add-init-hook

PRIVATE>

: open-game-input ( -- )
    game-input-opened? [
        (open-game-input) 
        game-input-opened on
    ] unless ;
: close-game-input ( -- )
    game-input-opened? [
        (close-game-input) 
        reset-game-input
    ] when ;

: with-game-input ( quot -- )
    open-game-input [ close-game-input ] [ ] cleanup ; inline

TUPLE: controller handle ;
TUPLE: controller-state x y z rx ry rz slider pov buttons ;

M: controller-state clone
    call-next-method dup buttons>> clone >>buttons ;

SYMBOLS:
    pov-neutral
    pov-up pov-up-right pov-right pov-down-right
    pov-down pov-down-left pov-left pov-up-left ;

HOOK: get-controllers game-input-backend ( -- sequence )

HOOK: product-string game-input-backend ( controller -- string )
HOOK: product-id game-input-backend ( controller -- id )
HOOK: instance-id game-input-backend ( controller -- id )

: find-controller-products ( product-id -- sequence )
    get-controllers [ product-id = ] with filter ;
: find-controller-instance ( product-id instance-id -- controller/f )
    get-controllers [
        tuck
        [ product-id  = ]
        [ instance-id = ] 2bi* and
    ] with with find nip ;

HOOK: read-controller game-input-backend ( controller -- controller-state )
HOOK: calibrate-controller game-input-backend ( controller -- )

TUPLE: keyboard-state keys ;

M: keyboard-state clone
    call-next-method dup keys>> clone >>keys ;

HOOK: read-keyboard game-input-backend ( -- keyboard-state )

TUPLE: mouse-state dx dy scroll-dx scroll-dy buttons ;

M: mouse-state clone
    call-next-method dup buttons>> clone >>buttons ;

HOOK: read-mouse game-input-backend ( -- mouse-state )

HOOK: reset-mouse game-input-backend ( -- )

{
    { [ os windows? ] [ "game-input.dinput" require ] }
    { [ os macosx? ] [ "game-input.iokit" require ] }
    { [ t ] [ ] }
} cond
