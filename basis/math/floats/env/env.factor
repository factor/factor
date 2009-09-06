! (c)Joe Groff bsd license
USING: alien.syntax assocs biassocs combinators continuations
generalizations kernel literals locals math math.bitwise
sequences system ;
IN: math.floats.env


SINGLETONS:
    +fp-invalid-operation+
    +fp-overflow+
    +fp-underflow+
    +fp-zero-divide+
    +fp-inexact+ ;

UNION: fp-exception
    +fp-invalid-operation+
    +fp-overflow+
    +fp-underflow+
    +fp-zero-divide+
    +fp-inexact+ ;

SINGLETONS:
    +round-nearest+
    +round-down+
    +round-up+
    +round-zero+ ;

UNION: fp-rounding-mode
    +round-nearest+
    +round-down+
    +round-up+
    +round-zero+ ;

SINGLETONS:
    +denormal-keep+
    +denormal-flush+ ;

UNION: fp-denormal-mode
    +denormal-keep+
    +denormal-flush+ ;

<PRIVATE

! These functions are provided in the VM; see cpu-*.S
FUNCTION: uint get_fp_control_register ( ) ;
FUNCTION: void set_fp_control_register ( uint reg ) ;

HOOK: exception-flag-bits    cpu ( -- bits )
HOOK: exception-flag>bit     cpu ( -- assoc )
HOOK: exception-enable-bits  cpu ( -- bits )
HOOK: exception-enable>bit   cpu ( -- assoc )
HOOK: >exception-enable      cpu ( mask -- enable )
HOOK: rounding-mode-bits     cpu ( -- bits )
HOOK: rounding-mode>bit      cpu ( -- assoc )
HOOK: denormal-mode-bits     cpu ( -- bits )

M: x86 exception-flag-bits HEX: 3f ;
M: x86 exception-flag>bit
    H{
        { +fp-invalid-operation+ HEX: 01 }
        { +fp-overflow+          HEX: 08 }
        { +fp-underflow+         HEX: 10 }
        { +fp-zero-divide+       HEX: 04 }
        { +fp-inexact+           HEX: 20 }
    } ;

M: x86 exception-enable-bits HEX: 1f80 ;
M: x86 exception-enable>bit
    H{
        { +fp-invalid-operation+ HEX: 0080 }
        { +fp-overflow+          HEX: 0400 }
        { +fp-underflow+         HEX: 0800 }
        { +fp-zero-divide+       HEX: 0200 }
        { +fp-inexact+           HEX: 1000 }
    } ;

M: x86 >exception-enable bitnot ;

M: x86 rounding-mode-bits HEX: 6000 ;
M: x86 rounding-mode>bit
    $[ H{
        { +round-nearest+ HEX: 0000 }
        { +round-down+    HEX: 2000 }
        { +round-up+      HEX: 4000 }
        { +round-zero+    HEX: 6000 }
    } >biassoc ] ;

M: x86 denormal-mode-bits HEX: 8040 ;

M: ppc exception-flag-bits HEX: 3e00,0000 ;
M: ppc exception-flag>bit
    H{
        { +fp-invalid-operation+ HEX: 2000,0000 }
        { +fp-overflow+          HEX: 1000,0000 }
        { +fp-underflow+         HEX: 0800,0000 }
        { +fp-zero-divide+       HEX: 0400,0000 }
        { +fp-inexact+           HEX: 0200,0000 }
    } ;

M: ppc exception-enable-bits HEX: f80 ;
M: ppc exception-enable>bit
    H{
        { +fp-invalid-operation+ HEX: 8000 }
        { +fp-overflow+          HEX: 4000 }
        { +fp-underflow+         HEX: 2000 }
        { +fp-zero-divide+       HEX: 1000 }
        { +fp-inexact+           HEX: 0800 }
    } ;

M: ppc >exception-enable ;

M: ppc rounding-mode-bits HEX: 3 ;
M: ppc rounding-mode>bit
    $[ H{
        { +round-nearest+ HEX: 0 }
        { +round-zero+    HEX: 1 }
        { +round-up+      HEX: 2 }
        { +round-down+    HEX: 3 }
    } >biassoc ] ;

M: ppc denormal-mode-bits HEX: 4 ;

:: mask> ( bits assoc -- symbols )
    assoc [| k v | bits v mask zero? not ] assoc-filter keys ;
: >mask ( symbols assoc -- bits )
    over empty?
    [ 2drop 0 ]
    [ [ at ] curry [ bitor ] map-reduce ] if ;

: remask ( x new-bits mask-bits -- x' )
    [ unmask ] [ mask ] bi-curry bi* bitor ; inline

: (get-exception-flags) ( register -- exceptions )
    exception-flag>bit mask> ; inline
: (set-exception-flags) ( register exceptions -- register' )
    exception-flag>bit >mask exception-flag-bits remask ; inline

: (get-exception-enable) ( register -- exceptions )
    >exception-enable exception-enable>bit mask> ; inline
: (set-exception-enable) ( register exceptions -- register' )
    exception-enable>bit >mask >exception-enable exception-enable-bits remask ; inline

: (get-rounding-mode) ( register -- mode )
    rounding-mode-bits mask rounding-mode>bit value-at ; inline
: (set-rounding-mode) ( register mode -- register' )
    rounding-mode>bit at rounding-mode-bits remask ; inline

: (get-denormal-mode) ( register -- mode )
    denormal-mode-bits mask zero? +denormal-keep+ +denormal-flush+ ? ; inline
: (set-denormal-mode) ( register ? -- register' )
    {
        { +denormal-keep+  [ denormal-mode-bits unmask ] }
        { +denormal-flush+ [ denormal-mode-bits bitor  ] }
    } case ; inline

: change-control-register ( quot -- )
    get_fp_control_register swap call set_fp_control_register ; inline

: get-exception-enable ( -- exceptions ) get_fp_control_register (get-exception-enable) ;
: set-exception-enable ( exceptions -- ) [ (set-exception-enable) ] curry change-control-register ;
: get-rounding-mode ( -- rounding-mode ) get_fp_control_register (get-rounding-mode) ;
: set-rounding-mode ( exceptions -- ) [ (set-rounding-mode) ] curry change-control-register ;
: get-denormal-mode ( -- ? ) get_fp_control_register (get-denormal-mode) ;
: set-denormal-mode ( ? -- ) [ (set-denormal-mode) ] curry change-control-register ;

: get-fp-env ( -- exception-flags exception-enable rounding-mode denormals? )
    get_fp_control_register {
        [ (get-exception-flags) ]
        [ (get-exception-enable) ]
        [ (get-rounding-mode) ]
        [ (get-denormal-mode) ]
    } cleave ;

: set-fp-env ( exception-flags exception-enable rounding-mode denormal-mode -- )
    [
        {
            [ [ (set-exception-flags) ] when* ]
            [ [ (set-exception-enable) ] when* ]
            [ [ (set-rounding-mode) ] when* ]
            [ [ (set-denormal-mode) ] when* ]
        } spread
    ] 4 ncurry change-control-register ;

PRIVATE>

: fp-exception-flags ( -- exceptions ) get_fp_control_register (get-exception-flags) ;
: set-fp-exception-flags ( exceptions -- ) [ (set-exception-flags) ] curry change-control-register ;
: clear-fp-exception-flags ( -- ) { } set-fp-exception-flags ; inline

: collect-fp-exceptions ( quot -- exceptions )
    clear-fp-exception-flags call fp-exception-flags ; inline

:: with-denormal-mode ( mode quot -- )
    get-denormal-mode :> orig
    mode set-denormal-mode
    quot [ orig set-denormal-mode ] [ ] cleanup ; inline

:: with-rounding-mode ( mode quot -- )
    get-rounding-mode :> orig
    mode set-rounding-mode
    quot [ orig set-rounding-mode ] [ ] cleanup ; inline

:: with-fp-traps ( exceptions quot -- )
    get-exception-enable :> orig
    exceptions set-exception-enable
    quot [ orig set-exception-enable ] [ ] cleanup ; inline

: without-fp-traps ( quot -- )
    { } swap with-fp-traps ; inline
