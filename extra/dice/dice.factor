! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: fry kernel lexer macros math math.parser peg.ebnf random
sequences strings ;

IN: dice

EBNF: parse-roll

number = ([0-9])+    => [[ >string string>number ]]
dice   = "d" number  => [[ second '[ _ random ] ]]
roll   = number dice => [[ first2 '[ 0 _ [ @ + 1 + ] times ] ]]
added  = "+" number  => [[ second '[ _ + ] ]]
total  = roll added? => [[ first2 [ append ] when* ]]
error  = .*          => [[ "unknown dice" throw ]]
rolls  = total | error

;EBNF

MACRO: roll ( string -- ) parse-roll ;

SYNTAX: ROLL: scan-token parse-roll append ;

