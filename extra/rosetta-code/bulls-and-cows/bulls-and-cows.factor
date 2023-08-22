! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators io kernel math
math.parser random ranges sequences ;
IN: rosetta-code.bulls-and-cows

! https://rosettacode.org/wiki/Bulls_and_cows

! This is an old game played with pencil and paper that was
! later implemented on computer.

! The task is for the program to create a four digit random
! number from the digits 1 to 9, without duplication. The program
! should ask for guesses to this number, reject guesses that are
! malformed, then print the score for the guess.

! The score is computed as:

! 1. The player wins if the guess is the same as the randomly
!    chosen number, and the program ends.

! 2. A score of one bull is accumulated for each digit in the
!    guess that equals the corresponding digit in the randomly
!    chosen initial number.

! 3. A score of one cow is accumulated for each digit in the
!    guess that also appears in the randomly chosen number, but in
!    the wrong position.

TUPLE: score bulls cows ;
: <score> ( -- score ) 0 0 score boa ;

TUPLE: cow ;
: <cow> ( -- cow ) cow new ;

TUPLE: bull ;
: <bull> ( -- bull ) bull new ;

: inc-bulls ( score -- score ) [ 1 + ] change-bulls ;
: inc-cows ( score -- score ) [ 1 + ] change-cows ;

: random-nums ( -- seq ) 9 [1..b] 4 sample ;

: add-digits ( seq -- n ) 0 [ swap 10 * + ] reduce number>string ;

: new-number ( -- n narr ) random-nums dup add-digits ;

: narr>nhash ( narr -- nhash ) { 1 2 3 4 } swap zip ;

: num>hash ( n -- hash )
    [ digit> ] { } map-as narr>nhash ;

:: cow-or-bull ( n g -- arr )
    {
        { [ n first g at n second = ] [ <bull> ] }
        { [ n second g value? ] [ <cow> ] }
        [ f ]
    } cond ;

: add-to-score ( arr -- score )
    <score> [ bull? [ inc-bulls ] [ inc-cows ] if ] reduce ;

: check-win ( score -- ? ) bulls>> 4 = ;

: sum-score ( n g -- score ? )
    '[ _ cow-or-bull ] map sift add-to-score dup check-win ;

: score-to-answer ( score -- str )
    [ bulls>> number>string "Bulls: " prepend ]
    [ cows>> number>string " Cows: " prepend ] bi "\n" glue ;

: (validate-readln) ( str -- ? )
    [ length 4 = not ]
    [ [ letter? ] all? ] bi or ;

: validate-readln ( -- str )
    readln dup (validate-readln)
    [
        "Invalid input.\nPlease enter a valid 4 digit number: "
        write flush drop validate-readln
    ] when ;

: win ( -- ) "You've won! Good job. You're so smart." print flush ;

: main-loop ( x -- )
    "Enter a 4 digit number: " write flush validate-readln num>hash swap
    [ sum-score swap score-to-answer print flush ] keep swap not
    [ main-loop ] [ drop win ] if ;

: bulls-and-cows-main ( -- ) new-number drop narr>nhash main-loop ;

MAIN: bulls-and-cows-main
