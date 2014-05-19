! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: interval-maps namespaces parser simple-flat-file
words.constant ;
IN: unicode.script

<PRIVATE

<<
"script-table" create-in
"vocab:unicode/script/Scripts.txt" load-interval-file
define-constant
>>

PRIVATE>

: script-of ( char -- script )
    script-table interval-at ;
