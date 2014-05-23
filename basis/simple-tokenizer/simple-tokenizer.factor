! Copyright (C) 2008, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: peg.ebnf strings ;
IN: simple-tokenizer

EBNF: tokenize
space = " "
escaped-char = "\" .:ch => [[ ch ]]
quoted = '"' (escaped-char | [^"])*:a '"' => [[ a ]]
unquoted = (escaped-char | [^ "])+
argument = (quoted | unquoted) => [[ >string ]]
command = space* (argument:a space* => [[ a ]])+:c !(.) => [[ c ]]
;EBNF
