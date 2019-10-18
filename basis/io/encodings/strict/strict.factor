! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings kernel accessors summary ;
IN: io.encodings.strict

TUPLE: strict-state code ;

C: strict strict-state

M: strict-state decode-char
    code>> decode-char dup replacement-char = [ decode-error ] when ;
