! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license
USING: fry kernel lexer macros math math.parser namespaces
random random.private sequences splitting ;
IN: dice

: (random-roll) ( #dice #sides obj -- n )
    [ 0 ] 3dip '[ _ _ (random-integer) + 1 + ] times ;

: random-roll ( #dice #sides -- n )
    random-generator get (random-roll) ;

: random-rolls ( length #dice #sides -- seq )
    random-generator get '[ _ _ _ (random-roll) ] replicate ;

: parse-roll ( string -- #dice #sides #added )
    "d" split1 "+" split1 [ string>number ] tri@ ;

: roll ( string -- n )
    parse-roll [ random-roll ] dip [ + ] when* ;

: roll-quot ( string -- quot: ( -- n ) )
    parse-roll [
        '[ _ _ random-roll _ + ]
    ] [
        '[ _ _ random-roll ]
    ] if* ;

SYNTAX: ROLL: scan-token roll-quot append! ;
