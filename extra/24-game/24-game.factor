! Copyright © 2008 Reginald Keith Ford II
! 24, the Factor game!

USING: kernel random namespaces shuffle sequences
parser io math prettyprint combinators continuations
vectors words quotations accessors math.parser
backtrack math.ranges locals fry memoize macros assocs ;

IN: 24-game

: nop ;
: do-something ( a b -- c ) { + - * } amb-execute ;
: maybe-swap ( a b -- a b ) { nop swap } amb-execute ;
: some-rots ( a b c -- a b c )
    #! Try each permutation of 3 elements.
    { nop rot -rot swap spin swapd } amb-execute ;
: makes-24? ( a b c d -- ? ) [ some-rots do-something some-rots do-something maybe-swap do-something 24 = ] [ 4drop ] if-amb ;
: vector-24-able? ( vector -- t/f ) [ makes-24? ] with-datastack first ;
: q ( -- obj ) "quit" ;
: show-commands ( -- ) "Commands: " write "commands" get unparse print ;
: report ( vector -- ) unparse print show-commands ;
: give-help ( -- ) "Command not found..." print show-commands ;
: find-word ( string choices -- word ) [ name>> = ] with find nip ;
: obtain-word ( -- word ) readln "commands" get find-word dup [ drop give-help obtain-word ] unless ;
: done? ( vector -- t/f ) 1 swap length = ;
: victory? ( vector -- t/f ) V{ 24 } = ;
: apply-word ( vector word -- vector ) 1quotation with-datastack >vector ;
: update-commands ( vector -- ) length 3 < [ "commands" [ \ rot swap remove ] change ] [ ] if ;
DEFER: check-status
: quit-game ( vector -- ) drop "you're a quitter" print ;
: quit? ( vector -- t/f ) peek "quit" = ;
: end-game ( vector -- ) dup victory? [ drop "You WON!" ] [ pop number>string " is not 24... You lose." append ] if print ;
: repeat ( vector -- ) dup report obtain-word apply-word dup update-commands check-status  ;
: check-status ( object -- ) dup done? [ end-game ] [ dup quit? [ quit-game ] [ repeat ] if ] if ;
: build-quad ( -- vector ) 4 [ 10 random ] replicate >vector ;
: 24-able ( -- vector ) build-quad dup vector-24-able? [ drop build-quad ] unless ;
: set-commands ( -- ) { + - * / rot swap q } "commands" set ;
: play-game ( -- ) set-commands 24-able repeat ;