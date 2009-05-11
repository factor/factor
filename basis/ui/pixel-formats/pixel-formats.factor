USING: accessors assocs classes destructors functors kernel
lexer math parser sequences specialized-arrays.int ui.backend
words ;
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

HOOK: (make-pixel-format) ui-backend ( world attributes -- pixel-format-handle )
HOOK: (free-pixel-format) ui-backend ( pixel-format -- )
HOOK: (pixel-format-attribute) ui-backend ( pixel-format attribute-name -- value )

ERROR: invalid-pixel-format-attributes world attributes ;

TUPLE: pixel-format world handle ;

: <pixel-format> ( world attributes -- pixel-format )
    2dup (make-pixel-format)
    [ nip pixel-format boa ] [ invalid-pixel-format-attributes ] if* ;

M: pixel-format dispose
    [ (free-pixel-format) ] [ f >>handle drop ] bi ;

: pixel-format-attribute ( pixel-format attribute-name -- value )
    (pixel-format-attribute) ;

<PRIVATE

FUNCTOR: define-pixel-format-attribute-table ( NAME PERM TABLE -- )

>PFA              DEFINES >${NAME}
>PFA-int-array    DEFINES >${NAME}-int-array

WHERE

GENERIC: >PFA ( attribute -- pfas )

M: object >PFA
    drop { } ;
M: word >PFA
    TABLE at [ { } ] unless* ;
M: pixel-format-attribute >PFA
    dup class TABLE at
    [ swap value>> suffix ]
    [ drop { } ] if* ;

: >PFA-int-array ( attribute -- int-array )
    [ >PFA ] map concat PERM prepend 0 suffix >int-array ;

;FUNCTOR

SYNTAX: PIXEL-FORMAT-ATTRIBUTE-TABLE:
    scan scan-object scan-object define-pixel-format-attribute-table ;

PRIVATE>

GENERIC: world-pixel-format-attributes ( world -- attributes )

GENERIC# check-world-pixel-format 1 ( world pixel-format -- )

