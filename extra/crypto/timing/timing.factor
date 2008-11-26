USING: kernel math threads system calendar ;
IN: crypto.timing

: with-timing ( quot n -- )
    #! force the quotation to execute in, at minimum, n milliseconds
    millis 2slip millis - + milliseconds sleep ; inline
