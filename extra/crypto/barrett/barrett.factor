USING: kernel math math.functions ;
IN: crypto.barrett

: barrett-mu ( n size -- mu )
    #! Calculates Barrett's reduction parameter mu
    #! size = word size in bits (8, 16, 32, 64, ...)
    over log2 1+ over / 2 * >r 2 swap ^ r> ^ swap / floor ;

