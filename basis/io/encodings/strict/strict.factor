! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings kernel accessors summary ;
IN: io.encodings.strict

TUPLE: strict code ;

C: strict strict

M: strict decode-char
    code>> decode-char dup replacement-char = [ decode-error ] when ;
