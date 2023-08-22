! Copyright © 2008 Reginald Keith Ford II
! 24, the Factor game!
USING: accessors backtrack combinators combinators.smart
continuations formatting io kernel math prettyprint
quotations random sequences ;
IN: 24-game

: nop ( -- ) ;

: ?/ ( a b -- c ) [ drop 1/0. ] [ / ] if-zero ;

: do-operation ( a b -- c )
    { + - * ?/ } amb-execute ;

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
    [ random-4 dup first4 makes-24? not ] smart-loop ;

: q ( -- obj ) "quit" ;

CONSTANT: (operators) { + - * / rot swap q }

: operators ( array -- operators )
    length 3 < [ \ rot (operators) remove ] [ (operators) ] if ;

: find-operator ( operators string -- word/f )
    '[ name>> _ = ] find nip ;

: get-operator ( operators -- word )
    [ "Operators: %u\n" printf flush ]
    [
        [ readln find-operator ]
        [ "Operator not found..." print get-operator ] ?unless
    ] bi ;

: try-operator ( array -- array )
    [ pprint nl ]
    [ dup operators get-operator 1quotation with-datastack ]
    bi ;

: end-game ( array -- )
    first dup 24 = [
        drop "You WON!"
    ] [
        "%d is not 24... You lose." sprintf
    ] if print ;

: quit-game ( array -- )
    drop "you're a quitter" print ;

: play-24 ( array -- )
    {
        { [ dup length 1 = ] [ end-game ] }
        { [ dup last "quit" = ] [ quit-game ] }
        [ try-operator play-24 ]
    } cond ;

: 24-game ( -- ) make-24 play-24 ;

MAIN: 24-game
