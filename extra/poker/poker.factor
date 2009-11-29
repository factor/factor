! Copyright (c) 2009 Aaron Schaefer. All rights reserved.
! Copyright (c) 2009 Doug Coleman.
! The contents of this file are licensed under the Simplified BSD License
! A copy of the license is available at http://factorcode.org/license.txt
USING: accessors arrays ascii assocs binary-search combinators
fry kernel locals math math.bitwise math.combinatorics
math.order math.statistics poker.arrays random sequences
sequences.product splitting grouping lexer strings ;
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

CONSTANT: STRAIGHT_FLUSH   0
CONSTANT: FOUR_OF_A_KIND   1
CONSTANT: FULL_HOUSE       2
CONSTANT: FLUSH            3
CONSTANT: STRAIGHT         4
CONSTANT: THREE_OF_A_KIND  5
CONSTANT: TWO_PAIR         6
CONSTANT: ONE_PAIR         7
CONSTANT: HIGH_CARD        8

CONSTANT: SUIT_STR { "C" "D" "H" "S" }

CONSTANT: RANK_STR { "2" "3" "4" "5" "6" "7" "8" "9" "T" "J" "Q" "K" "A" }

CONSTANT: VALUE_STR { "Straight Flush" "Four of a Kind" "Full House" "Flush"
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

#! Cactus Kev Format
GENERIC: >ckf ( string -- n )

M: string >ckf >upper 1 cut (>ckf) ;
M: integer >ckf ;

: parse-cards ( string -- seq )
    " " split [ >ckf ] map ;

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

: >card-rank ( card -- string )
    -8 shift HEX: F bitand RANK_STR nth ;

: >card-suit ( card -- string )
    {
        { [ dup 15 bit? ] [ drop "C" ] }
        { [ dup 14 bit? ] [ drop "D" ] }
        { [ dup 13 bit? ] [ drop "H" ] }
        [ drop "S" ]
    } cond ;

: value>rank ( value -- rank )
    {
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

: card>string ( n -- string )
    [ >card-rank ] [ >card-suit ] bi append ;

PRIVATE>

: <deck> ( -- deck )
    RANK_STR SUIT_STR 2array
    [ concat >ckf ] V{ } product-map-as ;

: best-holdem-hand ( hand -- n cards )
    5 [ [ hand-value ] [ ] bi ] { } map>assoc-combinations
    infimum first2 ;

: value>string ( n -- string )
    value>rank VALUE_STR nth ;

: hand>card-names ( hand -- string )
    [ card>string ] map ;

: string>value ( string -- value )
    parse-cards best-holdem-hand drop ;

: shuffle ( deck -- deck )
    [ randomize ] change-cards ;

ERROR: no-card card deck ;

: draw-specific-card ( card deck -- card )
    [ >ckf ] dip
    2dup index [ swap remove-nth! drop ] [ no-card ] if* ;

: start-hands ( seq -- seq' deck )
    <deck> [ '[ [ _ draw-specific-card ] map ] map ] keep ;

:: holdem-hand% ( hole1 deck community n -- x )
    community length 5 swap - 2 + :> #samples
    n [
        drop
        deck #samples sample :> sampled
        sampled 2 cut :> ( hole2 community2 )
        hole1 community community2 3append :> hand1
        hole2 community community2 3append :> hand2
        hand1 hand2 [ best-holdem-hand 2array ] bi@ <=> +lt+ =
    ] count ;

:: compare-holdem-hands ( holes deck n -- seq )
    n [
        holes deck 5 sample '[
            [ _ append best-holdem-hand drop ] keep
        ] { } map>assoc infimum second
    ] replicate histogram ;

: (best-omaha-hand) ( seq -- pair )
    4 cut
    [ 2 all-combinations ] [ 3 all-combinations ] bi*
    2array [ concat [ best-holdem-hand drop ] keep ] { } product-map>assoc ;

: best-omaha-hand ( seq -- n cards ) (best-omaha-hand) infimum first2 ;

:: compare-omaha-hands ( holes deck n -- seq )
    n [
        holes deck 5 sample '[
            [ _ append best-omaha-hand drop ] keep
        ] { } map>assoc infimum second
    ] replicate histogram ;

ERROR: bad-suit-symbol ch ;

: symbol>suit ( ch -- ch' )
    ch>upper
    H{
        { CHAR: ♠ CHAR: S }
        { CHAR: ♦ CHAR: D }
        { CHAR: ♥ CHAR: H }
        { CHAR: ♣ CHAR: C }
        { CHAR: S CHAR: S }
        { CHAR: D CHAR: D }
        { CHAR: H CHAR: H }
        { CHAR: C CHAR: C }
    } ?at [ bad-suit-symbol ] unless ;

: card> ( string -- card )
    1 over [ symbol>suit ] change-nth >ckf ;

: value>hand-name ( value -- string )
    value>rank VALUE_STR nth ;

SYNTAX: HAND{
    "}" parse-tokens [ card> ] { } map-as suffix! ;
