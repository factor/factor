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

: product-value ( product quot: ( model -- value ) -- seq )
    [ dependencies>> ] dip map ; inline

: set-product-value ( seq product quot: ( value model -- ) -- )
    [ dependencies>> ] dip 2each ; inline

M: product model-changed
    nip
    dup [ value>> ] product-value >>value
    notify-connections ;

M: product model-activated dup model-changed ;

M: product update-model
    [ value>> ] keep [ set-model ] set-product-value ;
