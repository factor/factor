! (c)Joe Groff bsd license
USING: alien.syntax assocs biassocs combinators continuations
generalizations kernel literals locals math math.bitwise
sequences system vocabs.loader ;
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

HOOK: (fp-env-registers) cpu ( -- registers )

: fp-env-register ( -- register ) (fp-env-registers) first ;

:: mask> ( bits assoc -- symbols )
    assoc [| k v | bits v mask zero? not ] assoc-filter keys ;
: >mask ( symbols assoc -- bits )
    over empty?
    [ 2drop 0 ]
    [ [ at ] curry [ bitor ] map-reduce ] if ;

: remask ( x new-bits mask-bits -- x' )
    [ unmask ] [ mask ] bi-curry bi* bitor ; inline

GENERIC: (set-fp-env-register) ( fp-env -- )

GENERIC: (get-exception-flags) ( fp-env -- exceptions )
GENERIC# (set-exception-flags) 1 ( fp-env exceptions -- fp-env )

GENERIC: (get-fp-traps) ( fp-env -- exceptions )
GENERIC# (set-fp-traps) 1 ( fp-env exceptions -- fp-env )

GENERIC: (get-rounding-mode) ( fp-env -- mode )
GENERIC# (set-rounding-mode) 1 ( fp-env mode -- fp-env )

GENERIC: (get-denormal-mode) ( fp-env -- mode )
GENERIC# (set-denormal-mode) 1 ( fp-env mode -- fp-env )

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

PRIVATE>

: fp-exception-flags ( -- exceptions ) fp-env-register (get-exception-flags) ;
: set-fp-exception-flags ( exceptions -- ) [ (set-exception-flags) ] curry change-fp-env-registers ;
: clear-fp-exception-flags ( -- ) { } set-fp-exception-flags ; inline

: collect-fp-exceptions ( quot -- exceptions )
    clear-fp-exception-flags call fp-exception-flags ; inline

: denormal-mode ( -- mode ) fp-env-register (get-denormal-mode) ;

:: with-denormal-mode ( mode quot -- )
    denormal-mode :> orig
    mode set-denormal-mode
    quot [ orig set-denormal-mode ] [ ] cleanup ; inline

: rounding-mode ( -- mode ) fp-env-register (get-rounding-mode) ;

:: with-rounding-mode ( mode quot -- )
    rounding-mode :> orig
    mode set-rounding-mode
    quot [ orig set-rounding-mode ] [ ] cleanup ; inline

: fp-traps ( -- exceptions ) fp-env-register (get-fp-traps) ;

:: with-fp-traps ( exceptions quot -- )
    fp-traps :> orig
    exceptions set-fp-traps
    quot [ orig set-fp-traps ] [ ] cleanup ; inline

: without-fp-traps ( quot -- )
    { } swap with-fp-traps ; inline

<< {
    { [ cpu x86? ] [ "math.floats.env.x86" require ] }
    { [ cpu ppc? ] [ "math.floats.env.ppc" require ] }
    [ "CPU architecture unsupported by math.floats.env" throw ]
} cond >>

