! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel models sequences ;
IN: models.product

TUPLE: product < model ;

: new-product ( models class -- product )
    f swap new-model
        swap clone >>dependencies ; inline

: <product> ( models -- product )
    product new-product ;

: product-value ( model quot -- seq )
    [ dependencies>> ] dip map ; inline

: set-product-value ( seq model quot -- )
    [ dependencies>> ] dip 2each ; inline

M: product model-changed
    nip
    dup [ value>> ] product-value >>value
    notify-connections ;

M: product model-activated dup model-changed ;

M: product update-model
    [ value>> ] keep [ set-model ] set-product-value ;

M: product range-value
    [ range-value ] product-value ;

M: product range-page-value
    [ range-page-value ] product-value ;

M: product range-min-value
    [ range-min-value ] product-value ;

M: product range-max-value
    [ range-max-value ] product-value ;

M: product range-max-value*
    [ range-max-value* ] product-value ;

M: product set-range-value
    [ clamp-value ] keep
    [ set-range-value ] set-product-value ;

M: product set-range-page-value
    [ set-range-page-value ] set-product-value ;

M: product set-range-min-value
    [ set-range-min-value ] set-product-value ;

M: product set-range-max-value
    [ set-range-max-value ] set-product-value ;
