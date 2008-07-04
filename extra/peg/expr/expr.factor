! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays strings math.parser sequences
peg peg.ebnf peg.parsers memoize math accessors ;
IN: peg.expr

EBNF: expr 
digit    = [0-9]            => [[ digit> ]]
number   = (digit)+         => [[ 10 digits>integer ]]
value    =   number 
           | ("(" exp ")")  => [[ second ]]

fac      =   fac "*" value  => [[ first3 nip * ]]
           | fac "/" value  => [[ first3 nip / ]]
           | number

exp      =   exp "+" fac    => [[ first3 nip + ]]
           | exp "-" fac    => [[ first3 nip - ]]
           | fac
;EBNF
