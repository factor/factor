! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: db2.utils

: ?when ( object quot -- object' ) dupd when ; inline

: assoc-with ( object sequence quot -- obj curry )
    swapd [ [ -rot ] dip  call ] 2curry ; inline
