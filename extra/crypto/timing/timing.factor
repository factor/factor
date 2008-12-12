! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math threads system calendar ;
IN: crypto.timing

: with-timing ( quot n -- )
    #! force the quotation to execute in, at minimum, n milliseconds
    millis 2slip millis - + milliseconds sleep ; inline
