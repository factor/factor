! :sidekick.parser=none:

IN: graphics

USE: alien
USE: combinators
USE: errors
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: sdl
USE: stack
USE: vectors
USE: oop

: black 0 0 0 255 rgba ;
: white 255 255 255 255 rgba ;

: clear-surface ( -- )
    #! Crappy
    surface get
    NULL
    surface get surface-format 255 255 255 SDL_MapRGB
    SDL_FillRect drop ;

! These variables are set in shape objects.
SYMBOL: from ( complex number, x/y )
SYMBOL: to ( complex number, w/h )
SYMBOL: filled?
SYMBOL: color
SYMBOL: string ( text objects only )

! Draw an object.
GENERIC: draw ( obj -- )

! Return if the point is inside the object.
GENERIC: inside? ( #{ x y } obj -- ? )

! Scale factor for all rendering, can be set in object too
SYMBOL: scale

! Translation
SYMBOL: origin

: center ( -- #{ x y } )
    width get 2 / height get 2 / rect> ;

: scene>screen ( #{ x y } -- #{ x y } )
    origin get - scale get * center + ;

: screen>scene ( #{ x y } -- #{ x y } )
    center - scale get / origin get + ;

: 2>irect >r >rect swap >fixnum swap >fixnum r> >rect swap >fixnum swap >fixnum ;

: (rect) ( -- surface x y w h color )
    surface get
    from get scene>screen
    to get scene>screen
    2>irect  color get ;

: in-rect? ( #{ x y } #{ x1 y1 } #{ x2 y2 } -- ? )
    #! Return if x/y is in the rectangle bounded by x1/y1, x2/y2
    3dup
    rot real rot real rot real between? >r
    rot imaginary rot imaginary rot imaginary between? r> and ;

TRAITS: rectangle
M: rectangle draw ( -- )
    (rect) filled? get [
        boxColor
    ] [
        rectangleColor
    ] ifte ;M

M: rectangle inside? ( #{ x y } -- ? )
    from get to get in-rect? ;M

TRAITS: line
M: line draw ( -- )
    (rect) lineColor ;M

M: line inside? ( #{ x y } -- ? )
    from get to get in-rect? [
        t
    ] [
        f
    ] ifte ;M

TRAITS: text
M: text draw ( -- )
    surface get  from get >rect  color get  string get
    stringColor ;M

: grab ( #{ x y } list -- shape )
    #! Return shape containing x/y.
    dup [
        2dup car inside? [ nip car ] [ cdr grab ] ifte
    ] [
        2drop f
    ] ifte ;
