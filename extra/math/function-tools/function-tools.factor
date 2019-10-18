! Copyright (c) 2008 Reginald Keith Ford II.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math arrays sequences ;
IN: math.function-tools

! Tools for quickly comparing, transforming, and evaluating mathematical functions

: difference-func ( func func -- func )
    [ bi - ] 2curry ; inline

: eval ( x func -- pt )
    dupd call( x -- y ) 2array ; inline

: eval-inverse ( y func -- pt )
    dupd call( y -- x ) swap 2array ; inline

: eval3d ( x y func -- pt )
    [ 2dup ] dip call( x y -- z ) 3array ; inline
