! Copyright (C) 2008 Chris Double.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.parser multiline peg.ebnf sequences ;
IN: peg.expr

EBNF: expr [=[
number   = ([0-9])+         => [[ string>number ]]
value    =   number
           | ("(" exp ")")  => [[ second ]]

fac      =   fac "*" value  => [[ first3 nip * ]]
           | fac "/" value  => [[ first3 nip / ]]
           | value

exp      =   exp "+" fac    => [[ first3 nip + ]]
           | exp "-" fac    => [[ first3 nip - ]]
           | fac
]=]
