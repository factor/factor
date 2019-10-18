! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: math
USING: generic kernel math-internals ;

DEFER: float?
BUILTIN: float 5 float? ;
UNION: real rational float ;

M: real abs dup 0 < [ neg ] when ;

M: real hashcode ( n -- n ) >fixnum ;

M: float number= float= ;
M: float < float< ;
M: float <= float<= ;
M: float > float> ;
M: float >= float>= ;

M: float + float+ ;
M: float - float- ;
M: float * float* ;
M: float / float/f ;
M: float /f float/f ;
