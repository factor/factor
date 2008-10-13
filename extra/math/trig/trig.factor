! Copyright (C) 2008 Eduardo Cavazos.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.constants ;
IN: math.trig

: deg>rad pi * 180 / ; inline
: rad>deg 180 * pi / ; inline
