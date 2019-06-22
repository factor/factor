! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: interval-maps namespaces parser simple-flat-file
words.constant ;
IN: unicode.script

<<
"script-table" create-word-in
"vocab:unicode/UCD/Scripts.txt" load-interval-file
define-constant
>>
