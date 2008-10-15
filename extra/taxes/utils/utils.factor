! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: math ;
IN: taxes.utils

: monthly ( x -- y ) 12 / ;
: semimonthly ( x -- y ) 24 / ;
: biweekly ( x -- y ) 26 / ;
: weekly ( x -- y ) 52 / ;
: daily ( x -- y ) 360 / ;
