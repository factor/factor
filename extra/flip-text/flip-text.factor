! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: assocs kernel sequences ;

IN: flip-text

<PRIVATE

CONSTANT: CHARS H{
    { CHAR: A   0x2200 }
    { CHAR: B   0x10412 }
    { CHAR: C   0x03FD }
    { CHAR: D   0x15E1 }
    { CHAR: E   0x018E }
    { CHAR: F   0x2132 }
    { CHAR: G   0x2141 }
    ! { CHAR: H   CHAR: H }
    ! { CHAR: I   CHAR: I }
    { CHAR: J   0x148B }
    { CHAR: K   0x004B }
    { CHAR: L   0x2142 }
    { CHAR: M   CHAR: W   }
    ! { CHAR: N   CHAR: N }
    ! { CHAR: O   CHAR: O }
    { CHAR: P   0x0500 }
    { CHAR: Q   0x038C }
    { CHAR: R   0x1D1A }
    ! { CHAR: S   CHAR: S }
    { CHAR: T   0x22A5 }
    { CHAR: U   0x0548 }
    { CHAR: V   0x039B }
    { CHAR: W   CHAR: M   }
    ! { CHAR: X   CHAR: X }
    { CHAR: Y   0x2144 }
    ! { CHAR: Z   CHAR: Z }
    { CHAR: a   0x0250 }
    { CHAR: b   CHAR: q   }
    { CHAR: c   0x0254 }
    { CHAR: d   CHAR: p   }
    { CHAR: e   0x01DD }
    { CHAR: f   0x025F }
    { CHAR: g   0x1D77 } ! or 0183
    { CHAR: h   0x0265 }
    { CHAR: i   0x1D09 } ! or 0131
    { CHAR: j   0x027E } ! or 1E37
    { CHAR: k   0x029E }
    { CHAR: l   0x0283 } ! or 237
    { CHAR: m   0x026F }
    { CHAR: n   CHAR: u   }
    ! { CHAR: o   CHAR: o }
    { CHAR: p   CHAR: d   }
    { CHAR: q   CHAR: b   }
    { CHAR: r   0x0279 }
    ! { CHAR: s   CHAR: s }
    { CHAR: t   0x0287 }
    { CHAR: u   CHAR: n   }
    { CHAR: v   0x028C }
    { CHAR: w   0x028D }
    { CHAR: y   0x028E }
    ! { CHAR: z   CHAR: z }
    ! { CHAR: 0   CHAR: 0 }
    { CHAR: 1   0x21C2 }
    { CHAR: 2   0x1105 }
    { CHAR: 3   0x0190 } ! or 1110
    { CHAR: 4   0x152D }
    ! { CHAR: 5   CHAR: 5 }
    { CHAR: 6   CHAR: 9   }
    { CHAR: 7   0x2C62 }
    ! { CHAR: 8   CHAR: 8 }
    { CHAR: 9   CHAR: 6   }
    { CHAR: &   0x214B }
    { CHAR: !   0x00A1 }
    { CHAR: \"   0x201E }
    { CHAR: .   0x02D9 }
    { CHAR: ;   0x061B }
    { CHAR: [   CHAR: ]   }
    { CHAR: (   CHAR: )   }
    { CHAR: {   CHAR: }   }
    { CHAR: ?   0x00BF }
    { CHAR: !   0x00A1 }
    { CHAR: '   CHAR: ,   }
    { CHAR: <   CHAR: >   }
    { CHAR: _   0x203E }
    { 0x203F 0x2040 }
    { 0x2045 0x2046 }
    { 0x2234 0x2235 }
    { CHAR: \r CHAR: \n   }
}

CHARS [ CHARS set-at ] assoc-each

: ch>flip ( ch -- ch' )
    [ CHARS at ] transmute ;

PRIVATE>

: flip-text ( str -- str' )
    [ ch>flip ] map reverse ;
