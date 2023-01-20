! Copyright (C) 2019-2020 KUSUMOTO Norio.
! See https://factorcode.org/license.txt for BSD license.
USING: logic kernel assocs math ;
IN: logic.examples.factorial

LOGIC-PREDS: factorial ;
LOGIC-VARS: N F N2 F2 ;

{ factorial N F } {
    { (>) N 0 }
    [ [ N of 1 - ] N2 is ]
    { factorial N2 F2 }
    [ [ [ F2 of ] [ N of ] bi * ] F is ] !!
} rule
{ factorial 0 1 } fact
