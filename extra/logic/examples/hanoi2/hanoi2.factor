! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: logic lists sequences assocs formatting ;
IN: logic.examples.hanoi2

LOGIC-PREDS: hanoi write-move ;
LOGIC-VARS: A B C X Y Z ;

{ write-move X } [ X of [ printf ] each t ] callback

{ hanoi L{ } A B C } fact

{ hanoi L{ X . Y } A B C } {
    { hanoi Y A C B }
    { write-move { "move " X " from " A " to " B "\n" } }
    { hanoi Y C B A }
} rule
