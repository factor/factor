! Copyright © 2008 Reginald Keith Ford II
! Tools for quickly comparing and evaluating mathematical Factor functions

USING: kernel math arrays ;
IN: math.function-tools 
: difference-func ( func func -- func ) [ bi - ] 2curry ;
: eval ( x func -- pt ) dupd call 2array ;
: eval3d ( x y func -- pt ) [ 2dup ] dip call 3array ;