! Copyright (c) 2009 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii binary-search combinators kernel locals math
    math.bitwise math.order poker.arrays sequences splitting ;
IN: poker

! The algorithm used is based on Cactus Kev's Poker Hand Evaluator with
! the Senzee Perfect Hash Optimization:
!     http://www.suffecool.net/poker/evaluator.html
!     http://www.senzee5.com/2006/06/some-perfect-hash.html

<PRIVATE

! Bitfield Format for Card Values:

!     +-------------------------------------+
!     | xxxbbbbb bbbbbbbb ssssrrrr xxpppppp |
!     +-------------------------------------+
!       xxxAKQJT 98765432 CDHSrrrr xxpppppp
!     +-------------------------------------+
!     | 00001000 00000000 01001011 00100101 |  King of Diamonds
!     | 00000000 00001000 00010011 00000111 |  Five of Spades
!     | 00000010 00000000 10001001 00011101 |  Jack of Clubs

! p = prime number value of rank (deuce = 2, trey = 3, four = 5, ..., ace = 41)
! r = rank of card (deuce = 0, trey = 1, four = 2, ..., ace = 12)
! s = bit turned on depending on suit of card
! b = bit turned on depending on rank of card
! x = bit turned off, not used

CONSTANT: CLUB     8
CONSTANT: DIAMOND  4
CONSTANT: HEART    2
CONSTANT: SPADE    1

CONSTANT: DEUCE  0
CONSTANT: TREY   1
CONSTANT: FOUR   2
CONSTANT: FIVE   3
CONSTANT: SIX    4
CONSTANT: SEVEN  5
CONSTANT: EIGHT  6
CONSTANT: NINE   7
CONSTANT: TEN    8
CONSTANT: JACK   9
CONSTANT: QUEEN  10
CONSTANT: KING   11
CONSTANT: ACE    12

CONSTANT: STRAIGHT_FLUSH   1
CONSTANT: FOUR_OF_A_KIND   2
CONSTANT: FULL_HOUSE       3
CONSTANT: FLUSH            4
CONSTANT: STRAIGHT         5
CONSTANT: THREE_OF_A_KIND  6
CONSTANT: TWO_PAIR         7
CONSTANT: ONE_PAIR         8
CONSTANT: HIGH_CARD        9

CONSTANT: RANK_STR { "2" "3" "4" "5" "6" "7" "8" "9" "T" "J" "Q" "K" "A" }

CONSTANT: VALUE_STR { "" "Straight Flush" "Four of a Kind" "Full House" "Flush"
    "Straight" "Three of a Kind" "Two Pair" "One Pair" "High Card" }

: card-rank-prime ( rank -- n )
    RANK_STR index { 2 3 5 7 11 13 17 19 23 29 31 37 41 } nth ;

: card-rank ( rank -- n )
    {
        { "2" [ DEUCE ] }
        { "3" [ TREY  ] }
        { "4" [ FOUR  ] }
        { "5" [ FIVE  ] }
        { "6" [ SIX   ] }
        { "7" [ SEVEN ] }
        { "8" [ EIGHT ] }
        { "9" [ NINE  ] }
        { "T" [ TEN   ] }
        { "J" [ JACK  ] }
        { "Q" [ QUEEN ] }
        { "K" [ KING  ] }
        { "A" [ ACE   ] }
    } case ;

: card-suit ( suit -- n )
    {
        { "C" [ CLUB    ] }
        { "D" [ DIAMOND ] }
        { "H" [ HEART   ] }
        { "S" [ SPADE   ] }
    } case ;

: card-rank-bit ( rank -- n )
    RANK_STR index 1 swap shift ;

: card-bitfield ( rank rank suit rank -- n )
    {
        { card-rank-bit 16 }
        { card-suit 12 }
        { card-rank 8 }
        { card-rank-prime 0 }
    } bitfield ;

:: (>ckf) ( rank suit -- n )
    rank rank suit rank card-bitfield ;

: >ckf ( str -- n )
    #! Cactus Kev Format
    >upper 1 cut (>ckf) ;

: flush? ( cards -- ? )
    HEX: F000 [ bitand ] reduce 0 = not ;

: rank-bits ( cards -- q )
    0 [ bitor ] reduce -16 shift ;

: lookup ( cards table -- value )
    [ rank-bits ] dip nth ;

: map-product ( seq quot -- n )
    [ 1 ] 2dip [ dip * ] curry [ swap ] prepose each ; inline

: prime-bits ( cards -- q )
    [ HEX: FF bitand ] map-product ;

: perfect-hash-find ( q -- value )
    #! magic to convert a hand's unique identifying bits to the
    #! proper index for fast lookup in a table of hand values
    HEX: E91AAA35 +
    dup -16 shift bitxor
    dup   8 shift w+
    dup  -4 shift bitxor
    [ -8 shift HEX: 1FF bitand adjustments-table nth ]
    [ dup 2 shift w+ -19 shift ] bi
    bitxor values-table nth ;

: hand-value ( cards -- value )
    dup flush? [ flushes-table lookup ] [
        dup unique5-table lookup dup 0 > [ nip ] [
            drop prime-bits perfect-hash-find
        ] if
    ] if ;

: >card-rank ( card -- str )
    -8 shift HEX: F bitand RANK_STR nth ;

: >card-suit ( card -- str )
    {
        { [ dup 15 bit? ] [ drop "C" ] }
        { [ dup 14 bit? ] [ drop "D" ] }
        { [ dup 13 bit? ] [ drop "H" ] }
        [ drop "S" ]
    } cond ;

: hand-rank ( hand -- rank )
    value>> {
        { [ dup 6185 > ] [ drop HIGH_CARD ] }        ! 1277 high card
        { [ dup 3325 > ] [ drop ONE_PAIR ] }         ! 2860 one pair
        { [ dup 2467 > ] [ drop TWO_PAIR ] }         !  858 two pair
        { [ dup 1609 > ] [ drop THREE_OF_A_KIND ] }  !  858 three-kind
        { [ dup 1599 > ] [ drop STRAIGHT ] }         !   10 straights
        { [ dup 322 > ]  [ drop FLUSH ] }            ! 1277 flushes
        { [ dup 166 > ]  [ drop FULL_HOUSE ] }       !  156 full house
        { [ dup 10 > ]   [ drop FOUR_OF_A_KIND ] }   !  156 four-kind
        [ drop STRAIGHT_FLUSH ]                      !   10 straight-flushes
    } cond ;

PRIVATE>

TUPLE: hand
    { cards sequence }
    { value integer } ;

M: hand <=> [ value>> ] compare ;
M: hand equal?
    over hand? [ [ value>> ] bi@ = ] [ 2drop f ] if ;

: <hand> ( str -- hand )
    " " split [ >ckf ] map
    dup hand-value hand boa ;

: >cards ( hand -- str )
    cards>> [
        [ >card-rank ] [ >card-suit ] bi append
    ] map " " join ;

: >value ( hand -- str )
    hand-rank VALUE_STR nth ;
