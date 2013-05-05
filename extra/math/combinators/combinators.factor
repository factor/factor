! Copyright (C) 2013 Loryn Jenkins.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math fry ;
IN: math.combinators

: when-negative ( ..n true: ( ..a -- ..b ) -- ..m )
    '[ _ dup 0 < [ @ ] when ] call ; inline
    
: when-positive ( ..n true: ( ..a -- ..b ) -- ..m )
    '[ _ dup 0 > [ @ ] when ] call ; inline 