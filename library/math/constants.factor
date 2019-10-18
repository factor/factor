! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USE: kernel

: i #{ 0 1 }# ; inline
: -i #{ 0 -1 }# ; inline
: inf 1.0 0.0 / ; inline
: -inf -1.0 0.0 / ; inline
: e 2.7182818284590452354 ; inline
: pi 3.14159265358979323846 ; inline
: pi/2 1.5707963267948966 ; inline

: deg>rad pi * 180 / ;
: rad>deg 180 * pi / ;
