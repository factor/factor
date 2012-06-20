! Copyright © 2008 Reginald Keith Ford II
! 24, the Factor game!

USING: accessors backtrack continuations io kernel math
math.parser prettyprint quotations random sequences shuffle ;

IN: 24-game

: nop ( -- ) ;

: do-operation ( a b -- c )
    { + - * } amb-execute ;

: permute-2 ( a b -- a b )
    { nop swap } amb-execute ;

: permute-3 ( a b c -- a b c )
    { nop rot -rot swap spin swapd } amb-execute ;

: makes-24? ( a b c d -- ? )
    [
        permute-3 do-operation
        permute-3 do-operation
        permute-2 do-operation
        24 =
    ] [ 4drop ] if-amb ;

: random-4 ( -- array )
    4 [ 10 random ] replicate ;

: make-24 ( -- array )
    f [ dup first4 makes-24? ] [ drop random-4 ] do until ;

: q ( -- obj ) "quit" ;

CONSTANT: (operators) { + - * / rot swap q }

: operators ( array -- operators )
    length 3 < [ \ rot (operators) remove ] [ (operators) ] if ;

: find-operator ( string operators -- word/f )
    [ name>> = ] with find nip ;

: get-operator ( operators -- word )
    "Operators: " write dup pprint nl flush
    readln over find-operator dup
    [ "Command not found..." print get-operator ] unless nip ;

: try-operator ( array -- array )
    [ pprint nl ]
    [ dup operators get-operator 1quotation with-datastack ]
    bi ;

: end-game ( array -- )
    dup { 24 } =
    [ drop "You WON!" ]
    [ first number>string " is not 24... You lose." append ]
    if print ;

: (24-game) ( array -- )
    dup length 1 =
    [ end-game ] [
        dup last "quit" =
        [ drop "you're a quitter" print ]
        [ try-operator (24-game) ]
        if
    ] if ;

: 24-game ( -- ) make-24 (24-game) ;

MAIN: 24-game
