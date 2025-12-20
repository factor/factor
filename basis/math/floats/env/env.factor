! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators continuations generalizations
kernel math math.bitwise sequences sets system vocabs ;
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

CONSTANT: all-fp-exceptions
    {
        +fp-invalid-operation+
        +fp-overflow+
        +fp-underflow+
        +fp-zero-divide+
        +fp-inexact+
    }

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

HOOK: (fp-env-registers) cpu ( -- registers )

: fp-env-register ( -- register ) (fp-env-registers) first ;

: mask> ( bits assoc -- symbols )
    [ mask zero? ] with reject-values keys ;
: >mask ( symbols assoc -- bits )
    over empty?
    [ 2drop 0 ]
    [ [ at ] curry [ bitor ] map-reduce ] if ;

: remask ( x new-bits mask-bits -- x' )
    [ unmask ] [ mask ] bi-curry bi* bitor ; inline

GENERIC: (set-fp-env-register) ( fp-env -- )

GENERIC: (get-exception-flags) ( fp-env -- exceptions )
GENERIC#: (set-exception-flags) 1 ( fp-env exceptions -- fp-env )

GENERIC: (get-fp-traps) ( fp-env -- exceptions )
GENERIC#: (set-fp-traps) 1 ( fp-env exceptions -- fp-env )

GENERIC: (get-rounding-mode) ( fp-env -- mode )
GENERIC#: (set-rounding-mode) 1 ( fp-env mode -- fp-env )

GENERIC: (get-denormal-mode) ( fp-env -- mode )
GENERIC#: (set-denormal-mode) 1 ( fp-env mode -- fp-env )

: change-fp-env-registers ( quot -- )
    (fp-env-registers) swap [ (set-fp-env-register) ] compose each ; inline

: set-fp-traps ( exceptions -- ) [ (set-fp-traps) ] curry change-fp-env-registers ;
: set-rounding-mode ( mode -- ) [ (set-rounding-mode) ] curry change-fp-env-registers ;
: set-denormal-mode ( mode -- ) [ (set-denormal-mode) ] curry change-fp-env-registers ;

: get-fp-env ( -- exception-flags fp-traps rounding-mode denormal-mode )
    fp-env-register {
        [ (get-exception-flags) ]
        [ (get-fp-traps) ]
        [ (get-rounding-mode) ]
        [ (get-denormal-mode) ]
    } cleave ;

: set-fp-env ( exception-flags fp-traps rounding-mode denormal-mode -- )
    [
        {
            [ [ (set-exception-flags) ] when* ]
            [ [ (set-fp-traps) ] when* ]
            [ [ (set-rounding-mode) ] when* ]
            [ [ (set-denormal-mode) ] when* ]
        } spread
    ] 4 ncurry change-fp-env-registers ;

CONSTANT: vm-error-exception-flag>bit
    H{
        { +fp-invalid-operation+ 0x01 }
        { +fp-overflow+          0x02 }
        { +fp-underflow+         0x04 }
        { +fp-zero-divide+       0x08 }
        { +fp-inexact+           0x10 }
    }

PRIVATE>

: fp-exception-flags ( -- exceptions )
    (fp-env-registers) [ (get-exception-flags) ] [ union ] map-reduce >array ; inline
: set-fp-exception-flags ( exceptions -- )
    [ (set-exception-flags) ] curry change-fp-env-registers ; inline
: clear-fp-exception-flags ( -- ) { } set-fp-exception-flags ; inline

: collect-fp-exceptions ( quot -- exceptions )
    [ clear-fp-exception-flags ] dip call fp-exception-flags ; inline

: vm-error>exception-flags ( error -- exceptions )
    third vm-error-exception-flag>bit mask> ;
: vm-error-exception-flag? ( error flag -- ? )
    vm-error>exception-flags member? ;

: denormal-mode ( -- mode ) fp-env-register (get-denormal-mode) ;

:: with-denormal-mode ( mode quot -- )
    denormal-mode :> orig
    mode set-denormal-mode
    quot [ orig set-denormal-mode ] finally ; inline

: rounding-mode ( -- mode ) fp-env-register (get-rounding-mode) ;

:: with-rounding-mode ( mode quot -- )
    rounding-mode :> orig
    mode set-rounding-mode
    quot [ orig set-rounding-mode ] finally ; inline

: fp-traps ( -- exceptions )
    (fp-env-registers) [ (get-fp-traps) ] [ union ] map-reduce >array ; inline

:: with-fp-traps ( exceptions quot -- )
    clear-fp-exception-flags
    fp-traps :> orig
    exceptions set-fp-traps
    quot [ orig set-fp-traps ] finally ; inline

: without-fp-traps ( quot -- )
    { } swap with-fp-traps ; inline

{
    { [ cpu x86? ] [ "math.floats.env.x86" require ] }
    { [ cpu ppc? ] [ "math.floats.env.ppc" require ] }
    { [ cpu arm.64? ] [ "math.floats.env.arm.64" require ] }
    [ "CPU architecture unsupported by math.floats.env" throw ]
} cond
