! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors fry kernel locals machine-learning.transformer
sequences sets sorting sorting.extras ;
IN: machine-learning.label-encoder

TUPLE: label-encoder classes_ ;

: <label-encoder> ( -- le ) label-encoder new ; inline

M: label-encoder fit-y ( y transformer -- )
    [ members natural-sort ] dip classes_<< ;

M: label-encoder transform-y ( y transformer -- y' )
    classes_>> '[ _ bisect-left ] map ;

M: label-encoder inverse-transform-y ( y' transformer -- y )
    classes_>> '[ _ nth ] map ;
