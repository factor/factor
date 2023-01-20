! Copyright (C) 2017 Alexander Ilin.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math opengl ;
IN: ui.gadgets.charts.utils

: default-color ( default obj -- )
    color>> dup [ swap ] unless gl-color drop ;

! value' = (value - min) / (max - min) * width
: scale ( width value max min -- value' ) neg [ + ] curry bi@ / * ;
