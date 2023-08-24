! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs logic math ;
IN: logic.examples.hanoi

LOGIC-PREDS: hanoi moveo informo ;
LOGIC-VARS: A B C M N X Y ;
SYMBOLS: left center right ;

{ hanoi N } { moveo N left center right } rule

{ moveo 0 __ __ __ } !! rule

{ moveo N A B C } {
    [ [ N of 1 - ] M is ]
    { moveo M A C B }
    { informo A B }
    { moveo M C B A }
} rule

{ informo X Y } {
    { writeo { "move disk from " X " to " Y } } { nlo }
} rule


