USING: destructors math ui.backend ;
IN: ui.pixel-formats

SINGLETONS:
    double-buffered
    stereo
    offscreen
    fullscreen
    windowed
    accelerated
    software-rendered
    robust
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

TUPLE: buffer-level < pixel-format-attribute ;

TUPLE: sample-buffers < pixel-format-attribute ;
TUPLE: samples < pixel-format-attribute ;

HOOK: (make-pixel-format) ui-backend ( attributes -- pixel-format-handle )
HOOK: (free-pixel-format) ui-backend ( pixel-format-handle -- )
HOOK: (pixel-format-attribute) ui-backend ( pixel-format-handle attribute-name -- value )

TUPLE: pixel-format { handle read-only } ;

: <pixel-format> ( attributes -- pixel-format )
    (make-pixel-format) pixel-format boa ;

M: pixel-format dispose
    [ [ (free-pixel-format) ] when* f ] change-handle drop ;

: pixel-format-attribute ( pixel-format attribute-name -- value )
    [ handle>> ] dip (pixel-format-attribute) ;

