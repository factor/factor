! Copyright (C) 2008, 2010 Slava Pestov
! See https://factorcode.org/license.txt for BSD license.
USING: peg.ebnf multiline strings ;
IN: simple-tokenizer

EBNF: tokenize [=[
space = [ \t\n\r]
escaped-char = "\\" .:ch => [[ ch ]]
quoted = '"' (escaped-char | [^"])*:a '"' => [[ a ]]
unquoted = (escaped-char | [^ \t\n\r"])+
argument = (quoted | unquoted) => [[ >string ]]
command = space* (argument:a space* => [[ a ]])+:c !(.) => [[ c ]]
]=]
