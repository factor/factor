! Copyright (C) 2013 Loryn Jenkins.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math ;
IN: math.combinators

: if-negative ( ..a n true: ( ..a n -- ..b ) false: ( ..a n -- ..b ) -- ..b )
    [ dup 0 < ] 2dip if ; inline

: if-positive ( ..a n true: ( ..a n -- ..b ) false: ( ..a n -- ..b ) -- ..b )
    [ dup 0 > ] 2dip if ; inline

: when-negative ( ..a n quot: ( ..a n -- ..b ) -- ..b )
    [ ] if-negative ; inline

: when-positive ( ..a n quot: ( ..a n -- ..b ) -- ..b )
    [ ] if-positive ; inline

: unless-negative ( ..a n quot: ( ..a n -- ..b ) -- ..b )
    [ ] swap if-negative ; inline

: unless-positive ( ..a n quot: ( ..a n -- ..b ) -- ..b )
    [ ] swap if-positive ; inline
