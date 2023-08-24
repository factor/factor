! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: logic lists ;
IN: logic.examples.zebra-short

! Do the same as this Prolog program
!
! neighbor(L,R,[L,R|_]).
! neighbor(L,R,[_|Xs]) :- neighbor(L,R,Xs).
!
! zebra(X) :- Street = [H1,H2,H3],
!             member(house(red,english,_), Street),
!             member(house(_,spanish,dog), Street),
!             neighbor(house(_,_,cat), house(_,japanese,_), Street),
!             neighbor(house(_,_,cat), house(blue,_,_), Street),
!             member(house(_,X,zebra),Street).

LOGIC-PREDS: neighboro zebrao ;
LOGIC-VARS: L R X Xs H1 H2 H3 Street ;
SYMBOLS: red blue ;
SYMBOLS: english spanish japanese ;
SYMBOLS: dog cat zebra ;
TUPLE: house color nationality pet ;

{ neighboro L R L{ L R . __ } } fact
{ neighboro L R L{ __ . Xs } } { neighboro L R Xs } rule

{ zebrao X } {
    { (=) Street L{ H1 H2 H3 } }
    { membero [ T{ house f red english __ } ] Street }
    { membero [ T{ house f __ spanish dog } ] Street }
    { neighboro [ T{ house f __ __ cat } ] [ T{ house f __ japanese __ } ]  Street }
    { neighboro [ T{ house f __ __ cat } ] [ T{ house f blue __ __ } ] Street }
    { membero [ T{ house f __ X zebra } ] Street }
} rule

