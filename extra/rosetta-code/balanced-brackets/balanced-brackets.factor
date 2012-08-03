! Copyright (c) 2012 Anonymous
! See http://factorcode.org/license.txt for BSD license.
USING: io formatting locals kernel math sequences unicode.case ;
IN: rosetta-code.balanced-brackets

! http://rosettacode.org/wiki/Balanced_brackets

! Task:

! Generate a string with N opening brackets (“[”) and N closing
! brackets (“]”), in some arbitrary order.

! Determine whether the generated string is balanced; that is,
! whether it consists entirely of pairs of opening/closing
! brackets (in that order), none of which mis-nest.

! Examples:

! (empty)   OK
! []        OK   ][        NOT OK
! [][]      OK   ][][      NOT OK
! [[][]]    OK   []][[]    NOT OK

:: balanced ( str -- )
   0 :> counter!
   1 :> ok!
   str
   [ dup length 0 > ]
   [ 1 cut swap
        "[" = [ counter 1 + counter! ] [ counter 1 - counter! ] if
        counter 0 < [ 0 ok! ] when
   ]
   while
   drop
   ok 0 =
   [ "NO" ]
   [ counter 0 > [ "NO" ] [ "YES" ] if ]
   if
   print ;
