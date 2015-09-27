! Copyright (c) 2012 Anonymous
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel locals math sequences ;
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

:: balanced? ( str -- ? )
    0 :> counter!
    t :> ok!
    str [
        {
            { CHAR: [ [ 1 ] }
            { CHAR: ] [ -1 ] }
            [ drop 0 ]
        } case counter + counter!
        counter 0 < [ f ok! ] when
    ] each
    ok [ counter 0 <= ] [ f ] if ;
