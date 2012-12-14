! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays fry kernel machine-learning.transformer
math.extras sequences sets sorting ;
IN: machine-learning.label-binarizer

TUPLE: label-binarizer classes_ ;

: <label-binarizer> ( -- lb )
    label-binarizer new ; inline

M: label-binarizer fit-y
    [ members natural-sort ] dip classes_<< ;

M: label-binarizer transform-y
    classes_>> dup length '[
        _ search-sorted [ 1 ] dip _ 0 <array> [ set-nth ] keep
    ] map ;

M: label-binarizer inverse-transform-y
    classes_>> '[
        [ 1 = ] find drop _ nth
    ] map ;
