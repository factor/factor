! Copyright (C) 2013 Loryn Jenkins.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: math.combinators

: if-negative ( ..a n true: ( ..a n -- ..b ) false: ( ..a n -- ..b ) -- ..b )
    [ dup 0 < ] 2dip if ; inline

: if-positive ( ..a n true: ( ..a n -- ..b ) false: ( ..a n -- ..b ) -- ..b )
    [ dup 0 > ] 2dip if ; inline

: when-negative ( ..a n true: ( ..a n -- ..b ) -- ..b )
    [ ] if-negative ; inline

: when-positive ( ..a n true: ( ..a n -- ..b ) -- ..b )
    [ ] if-positive ; inline
