! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays parser sequences vectors words.constant ;
IN: syntax.extras

SYMBOL: \ARRAY>
SYNTAX: \<ARRAY \ARRAY> parse-until >array suffix! ;

SYMBOL: \array>
SYNTAX: \<array \array> parse-until >array suffix! ;


SYMBOL: \;ARRAY>
SYNTAX: \<ARRAY:
    scan-new-word \;ARRAY> parse-until >array define-constant ;

SYMBOL: \VECTOR>
SYNTAX: \<VECTOR \VECTOR> parse-until >vector suffix! ;

SYMBOL: \;VECTOR>
SYNTAX: \<VECTOR:
    scan-new-word \;VECTOR> parse-until >vector define-constant ;
