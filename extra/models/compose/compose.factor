USING: models kernel sequences ;
IN: models.compose

TUPLE: compose ;

: <compose> ( models -- compose )
    f compose construct-model
    swap clone over set-model-dependencies ;

: composed-value >r model-dependencies r> map ; inline

: set-composed-value >r model-dependencies r> 2each ; inline

M: compose model-changed
    nip
    dup [ model-value ] composed-value swap delegate set-model ;

M: compose model-activated dup model-changed ;

M: compose update-model
    dup model-value swap [ set-model ] set-composed-value ;

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
