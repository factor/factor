! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.order sequences ;
IN: escape-strings

! TODO: Move the "]]" subseq? check into the each loop logic
: #escapes ( str -- n/f )
    [ f f f ] dip [
        {
            { char: = [ [ dup [ 1 + ] when ] bi@ ] }
            { char: ] [ [ [ 0 or ] 2dip [ max ] curry dip ] when* 0 ] }
            [ 2drop f ]
        } case
    ] each 2drop ;

: escape-string ( str -- str' )
    "]]" over subseq? [
        dup #escapes ?1+ char: = <repetition>
        [ "[" dup surround ] [ "]" dup surround ] bi surround
    ] [
        "[[" "]]" surround
    ] if ;