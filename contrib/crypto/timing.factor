IN: timing
USING: kernel threads ;

: with-timed ( quot n -- )
    #! force the quotation to execute in, at minimum, n milliseconds
    millis rot call millis swap - - sleep ;
