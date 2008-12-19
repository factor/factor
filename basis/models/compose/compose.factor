! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models kernel sequences ;
IN: models.compose

TUPLE: compose < model ;

: new-compose ( models class -- compose )
    f swap new-model
        swap clone >>dependencies ; inline

: <compose> ( models -- compose )
    compose new-compose ;

: composed-value [ dependencies>> ] dip map ; inline

: set-composed-value [ dependencies>> ] dip 2each ; inline

M: compose model-changed
    nip
    dup [ value>> ] composed-value >>value
    notify-connections ;

M: compose model-activated dup model-changed ;

M: compose update-model
    dup value>> swap [ set-model ] set-composed-value ;

M: compose range-value
    [ range-value ] composed-value ;

M: compose range-page-value
    [ range-page-value ] composed-value ;

M: compose range-min-value
    [ range-min-value ] composed-value ;

M: compose range-max-value
    [ range-max-value ] composed-value ;

M: compose range-max-value*
    [ range-max-value* ] composed-value ;

M: compose set-range-value
    [ clamp-value ] keep
    [ set-range-value ] set-composed-value ;

M: compose set-range-page-value
    [ set-range-page-value ] set-composed-value ;

M: compose set-range-min-value
    [ set-range-min-value ] set-composed-value ;

M: compose set-range-max-value
    [ set-range-max-value ] set-composed-value ;
