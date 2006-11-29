IN: timing
USING: kernel math threads ;

: with-timing ( n quot -- )
    #! force the quotation to execute in, at minimum, n milliseconds
    millis >r call millis r> - - sleep ;
