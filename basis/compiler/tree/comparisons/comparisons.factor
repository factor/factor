! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs combinators math math.intervals math.order ;
IN: compiler.tree.comparisons

! Some utilities for working with comparison operations.

CONSTANT: comparison-ops { < > <= >= u< u> u<= u>= }

CONSTANT: generic-comparison-ops { before? after? before=? after=? }

: assumption ( i1 i2 op -- i3 )
    {
        { \ <   [ assume< ] }
        { \ >   [ assume> ] }
        { \ <=  [ assume<= ] }
        { \ >=  [ assume>= ] }
        { \ u<  [ assume< ] }
        { \ u>  [ assume> ] }
        { \ u<= [ assume<= ] }
        { \ u>= [ assume>= ] }
    } case ;

: interval-comparison ( i1 i2 op -- result )
    {
        { \ <   [ interval< ] }
        { \ >   [ interval> ] }
        { \ <=  [ interval<= ] }
        { \ >=  [ interval>= ] }
        { \ u<  [ interval< ] }
        { \ u>  [ interval> ] }
        { \ u<= [ interval<= ] }
        { \ u>= [ interval>= ] }
    } case ;

: swap-comparison ( op -- op' )
    {
        { < > }
        { > < }
        { <= >= }
        { >= <= }
        { u< u> }
        { u> u< }
        { u<= u>= }
        { u>= u<= }
    } at ;

: negate-comparison ( op -- op' )
    {
        { < >= }
        { > <= }
        { <= > }
        { >= < }
        { u< u>= }
        { u> u<= }
        { u<= u> }
        { u>= u< }
    } at ;

: specific-comparison ( op -- op' )
    {
        { before? < }
        { after? > }
        { before=? <= }
        { after=? >= }
    } at ;
