! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.order math.intervals assocs combinators ;
IN: compiler.tree.comparisons

! Some utilities for working with comparison operations.

CONSTANT: comparison-ops { < > <= >= }

CONSTANT: generic-comparison-ops { before? after? before=? after=? }

: assumption ( i1 i2 op -- i3 )
    {
        { \ <  [ assume< ] }
        { \ >  [ assume> ] }
        { \ <= [ assume<= ] }
        { \ >= [ assume>= ] }
    } case ;

: interval-comparison ( i1 i2 op -- result )
    {
        { \ <  [ interval< ] }
        { \ >  [ interval> ] }
        { \ <= [ interval<= ] }
        { \ >= [ interval>= ] }
    } case ;

: swap-comparison ( op -- op' )
    {
        { < > }
        { > < }
        { <= >= }
        { >= <= }
    } at ;

: negate-comparison ( op -- op' )
    {
        { < >= }
        { > <= }
        { <= > }
        { >= < }
    } at ;

: specific-comparison ( op -- op' )
    {
        { before? < }
        { after? > }
        { before=? <= }
        { after=? >= }
    } at ;
