! Copyright (C) 2008 Eduardo Cavazos.
! See https://factorcode.org/license.txt for BSD license.
USING: math math.constants ;
IN: math.trig

: deg>rad ( x -- y ) pi * 180 / ; inline
: rad>deg ( x -- y ) 180 * pi / ; inline
