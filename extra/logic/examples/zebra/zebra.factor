! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.

! Zebra Puzzle: https://rosettacode.org/wiki/Zebra_puzzle

USING: logic lists ;
IN: logic.examples.zebra

LOGIC-PREDS: houseso neighboro zebrao watero nexto lefto ;
LOGIC-VARS: Hs A B Ls X Y ;
SYMBOLS: red blue green white yellow ;
SYMBOLS: english swede dane norwegian german ;
SYMBOLS: dog cat birds horse zebra ;
SYMBOLS: tea coffee beer milk water ;
SYMBOLS: pall-mall dunhill blue-master prince blend ;
TUPLE: house color nationality drink smoke pet ;

{ houseso Hs X Y } {
    { (=) Hs                                                                      ! #1
          L{ T{ house f __ norwegian __ __ __ }                                   ! #10
             T{ house f blue __ __ __ __ }                                        ! #15
             T{ house f __ __ milk __ __ }                                        ! #9
              __
              __ } }
    { membero T{ house f red english __ __ __ } Hs }                              ! #2
    { membero T{ house f __ swede __ __ dog } Hs }                                ! #3
    { membero T{ house f __ dane tea __ __ } Hs }                                 ! #4
    { lefto T{ house f green __ __ __ __ } T{ house f white __ __ __ __ } Hs }    ! #5
    { membero T{ house f green __ coffee __ __ } Hs }                             ! #6
    { membero T{ house f __ __ __ pall-mall birds } Hs }                          ! #7
    { membero T{ house f yellow __ __ dunhill __ } Hs }                           ! #8
    { nexto T{ house f __ __ __ blend __ } T{ house f __ __ __ __ cat } Hs }      ! #11
    { nexto T{ house f __ __ __ dunhill __ } T{ house f __ __ __ __ horse } Hs }  ! #12
    { membero T{ house f __ __ beer blue-master __ } Hs }                         ! #13
    { membero T{ house f __ german __ prince __ } Hs }                            ! #14
    { nexto T{ house f __ __ water __ __ } T{ house f __ __ __ blend __ } Hs }    ! #16
    { membero T{ house f __ X water __ __ } Hs }
    { membero T{ house f __ Y __ __ zebra } Hs }
} rule

{ nexto A B Ls } {
    { appendo __ L{ A B . __ } Ls } ;;
    { appendo __ L{ B A . __ } Ls }
} rule

{ lefto A B Ls } { appendo __ L{ A B . __ } Ls } rule

