! Copyright (C) 2008 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: io.encodings kernel ;
IN: io.encodings.binary

SINGLETON: binary
M: binary <encoder> drop ; inline
M: binary <decoder> drop ; inline
