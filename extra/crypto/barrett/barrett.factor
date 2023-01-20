! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math math.functions ;
IN: crypto.barrett

: barrett-mu ( n size -- mu )
    ! Calculates Barrett's reduction parameter mu
    ! size = word size in bits (8, 16, 32, 64, ...)
    [ [ log2 1 + ] [ / 2 * ] bi* ]
    [ 2^ rot ^ swap /i ] 2bi ;
