! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs kernel sequences ;

IN: flip-text

<PRIVATE

CONSTANT: CHARS H{
    { ch'A   0x2200 }
    { ch'B   0x10412 }
    { ch'C   0x03FD }
    { ch'D   0x15E1 }
    { ch'E   0x018E }
    { ch'F   0x2132 }
    { ch'G   0x2141 }
    ! { ch'H   ch'H }
    ! { ch'I   ch'I }
    { ch'J   0x148B }
    { ch'K   0x004B }
    { ch'L   0x2142 }
    { ch'M   ch'W   }
    ! { ch'N   ch'N }
    ! { ch'O   ch'O }
    { ch'P   0x0500 }
    { ch'Q   0x038C }
    { ch'R   0x1D1A }
    ! { ch'S   ch'S }
    { ch'T   0x22A5 }
    { ch'U   0x0548 }
    { ch'V   0x039B }
    { ch'W   ch'M   }
    ! { ch'X   ch'X }
    { ch'Y   0x2144 }
    ! { ch'Z   ch'Z }
    { ch'a   0x0250 }
    { ch'b   ch'q   }
    { ch'c   0x0254 }
    { ch'd   ch'p   }
    { ch'e   0x01DD }
    { ch'f   0x025F }
    { ch'g   0x1D77 } ! or 0183
    { ch'h   0x0265 }
    { ch'i   0x1D09 } ! or 0131
    { ch'j   0x027E } ! or 1E37
    { ch'k   0x029E }
    { ch'l   0x0283 } ! or 237
    { ch'm   0x026F }
    { ch'n   ch'u   }
    ! { ch'o   ch'o }
    { ch'p   ch'd   }
    { ch'q   ch'b   }
    { ch'r   0x0279 }
    ! { ch's   ch's }
    { ch't   0x0287 }
    { ch'u   ch'n   }
    { ch'v   0x028C }
    { ch'w   0x028D }
    { ch'y   0x028E }
    ! { ch'z   ch'z }
    ! { ch'0   ch'0 }
    { ch'1   0x21C2 }
    { ch'2   0x1105 }
    { ch'3   0x0190 } ! or 1110
    { ch'4   0x152D }
    ! { ch'5   ch'5 }
    { ch'6   ch'9   }
    { ch'7   0x2C62 }
    ! { ch'8   ch'8 }
    { ch'9   ch'6   }
    { ch'&   0x214B }
    { ch'\!   0x00A1 }
    { ch'\"   0x201E }
    { ch'.   0x02D9 }
    { ch'\;   0x061B }
    { ch'\[   ch'\]   }
    { ch'\(   ch'\)   }
    { ch'\{   ch'\}   }
    { ch'?   0x00BF }
    { ch'\!   0x00A1 }
    { ch'\'   ch',   }
    { ch'<   ch'>   }
    { ch'_   0x203E }
    { 0x203F 0x2040 }
    { 0x2045 0x2046 }
    { 0x2234 0x2235 }
    { ch'\r ch'\n   }
}

CHARS [ CHARS set-at ] assoc-each

: ch>flip ( ch -- ch' )
    dup CHARS at [ nip ] when* ;

PRIVATE>

: flip-text ( str -- str' )
    [ ch>flip ] map reverse ;
