! Copyright (C) 2008 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors io.encodings kernel ;
IN: io.encodings.strict

TUPLE: strict-state code ;

C: strict strict-state

M: strict-state decode-char
    code>> decode-char dup replacement-char = [ decode-error ] when ;
