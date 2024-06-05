USING: accessors alien.c-types alien.data assocs classes
combinators destructors kernel math sequences specialized-arrays
ui.backend words ;
SPECIALIZED-ARRAY: int
IN: ui.pixel-formats

SYMBOLS:
    double-buffered
    stereo
    offscreen
    fullscreen
    windowed
    accelerated
    software-rendered
    backing-store
    multisampled
    supersampled
    sample-alpha
    color-float ;

TUPLE: pixel-format-attribute { value integer } ;

TUPLE: color-bits < pixel-format-attribute ;
TUPLE: red-bits < pixel-format-attribute ;
TUPLE: green-bits < pixel-format-attribute ;
TUPLE: blue-bits < pixel-format-attribute ;
TUPLE: alpha-bits < pixel-format-attribute ;

TUPLE: accum-bits < pixel-format-attribute ;
TUPLE: accum-red-bits < pixel-format-attribute ;
TUPLE: accum-green-bits < pixel-format-attribute ;
TUPLE: accum-blue-bits < pixel-format-attribute ;
TUPLE: accum-alpha-bits < pixel-format-attribute ;

TUPLE: depth-bits < pixel-format-attribute ;

TUPLE: stencil-bits < pixel-format-attribute ;

TUPLE: aux-buffers < pixel-format-attribute ;

TUPLE: sample-buffers < pixel-format-attribute ;
TUPLE: samples < pixel-format-attribute ;

HOOK: (make-pixel-format) ui-backend ( world attributes --
                                       pixel-format-handle )
HOOK: (free-pixel-format) ui-backend ( pixel-format -- )

ERROR: invalid-pixel-format-attributes world attributes ;

TUPLE: pixel-format < disposable world handle ;

: <pixel-format> ( world attributes -- pixel-format )
    2dup (make-pixel-format) ?or*
    [ pixel-format new-disposable swap >>handle swap >>world ]
    [ invalid-pixel-format-attributes ]
    if ;

M: pixel-format dispose*
    [ (free-pixel-format) ] [ f >>handle drop ] bi ;

: (pixel-format-attribute) ( attribute table -- arr/f )
    [ dup class-of ] dip at [ swap value>> suffix ] [ drop f ] if* ;

: pixel-format-attribute>array ( obj table -- arr/f )
    {
        { [ over pixel-format-attribute? ] [ (pixel-format-attribute) ] }
        { [ over word? ] [ at ] }
        [ 2drop f ]
    } cond ;

: pixel-format-attributes>int-array ( attrs perm table -- arr )
    swapd '[ _ pixel-format-attribute>array ] map sift concat append
    ! 0 happens to work as a sentinel value for all ui backends.
    0 suffix int >c-array ;

GENERIC: world-pixel-format-attributes ( world -- attributes )

GENERIC#: check-world-pixel-format 1 ( world pixel-format -- )
