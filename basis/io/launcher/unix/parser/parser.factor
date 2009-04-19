! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: peg peg.ebnf arrays sequences strings kernel ;
IN: io.launcher.unix.parser

! Our command line parser. Supported syntax:
! foo bar baz -- simple tokens
! foo\ bar -- escaping the space
! "foo bar" -- quotation
EBNF: tokenize-command
space = " "
escaped-char = "\" .:ch => [[ ch ]]
quoted = '"' (escaped-char | [^"])*:a '"' => [[ a ]]
unquoted = (escaped-char | [^ "])+
argument = (quoted | unquoted) => [[ >string ]]
command = space* (argument:a space* => [[ a ]])+:c !(.) => [[ c ]]
;EBNF
