! Copyright (C) 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings kernel accessors inspector ;
IN: io.encodings.strict

TUPLE: strict code ;
C: strict strict

TUPLE: decode-error ;
: decode-error ( -- * ) \ decode-error construct-empty throw ;
M: decode-error summary
    drop "Error in decoding input stream" ;

M: strict <decoder>
    code>> <decoder> [ strict ] change-code ;

M: strict decode-char
    code>> decode-char dup replacement-char = [ decode-error ] when ;
