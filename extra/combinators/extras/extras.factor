! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: combinators.extras

: once ( quot -- ) call ; inline
: twice ( quot -- ) dup [ call ] dip call ; inline
: thrice ( quot -- ) dup dup [ call ] 2dip [ call ] dip call ; inline
