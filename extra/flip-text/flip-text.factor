! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs kernel sequences ;

IN: flip-text

<PRIVATE

CONSTANT: CHARS H{
    { char: A   0x2200 }
    { char: B   0x10412 }
    { char: C   0x03FD }
    { char: D   0x15E1 }
    { char: E   0x018E }
    { char: F   0x2132 }
    { char: G   0x2141 }
    ! { char: H   char: H }
    ! { char: I   char: I }
    { char: J   0x148B }
    { char: K   0x004B }
    { char: L   0x2142 }
    { char: M   char: W   }
    ! { char: N   char: N }
    ! { char: O   char: O }
    { char: P   0x0500 }
    { char: Q   0x038C }
    { char: R   0x1D1A }
    ! { char: S   char: S }
    { char: T   0x22A5 }
    { char: U   0x0548 }
    { char: V   0x039B }
    { char: W   char: M   }
    ! { char: X   char: X }
    { char: Y   0x2144 }
    ! { char: Z   char: Z }
    { char: a   0x0250 }
    { char: b   char: q   }
    { char: c   0x0254 }
    { char: d   char: p   }
    { char: e   0x01DD }
    { char: f   0x025F }
    { char: g   0x1D77 } ! or 0183
    { char: h   0x0265 }
    { char: i   0x1D09 } ! or 0131
    { char: j   0x027E } ! or 1E37
    { char: k   0x029E }
    { char: l   0x0283 } ! or 237
    { char: m   0x026F }
    { char: n   char: u   }
    ! { char: o   char: o }
    { char: p   char: d   }
    { char: q   char: b   }
    { char: r   0x0279 }
    ! { char: s   char: s }
    { char: t   0x0287 }
    { char: u   char: n   }
    { char: v   0x028C }
    { char: w   0x028D }
    { char: y   0x028E }
    ! { char: z   char: z }
    ! { char: 0   char: 0 }
    { char: 1   0x21C2 }
    { char: 2   0x1105 }
    { char: 3   0x0190 } ! or 1110
    { char: 4   0x152D }
    ! { char: 5   char: 5 }
    { char: 6   char: 9   }
    { char: 7   0x2C62 }
    ! { char: 8   char: 8 }
    { char: 9   char: 6   }
    { char: &   0x214B }
    { char: \!   0x00A1 }
    { char: \"   0x201E }
    { char: .   0x02D9 }
    { char: \;   0x061B }
    { char: \[   char: \]   }
    { char: \(   char: \)   }
    { char: \{   char: \}   }
    { char: ?   0x00BF }
    { char: \!   0x00A1 }
    { char: \'   char: ,   }
    { char: <   char: >   }
    { char: _   0x203E }
    { 0x203F 0x2040 }
    { 0x2045 0x2046 }
    { 0x2234 0x2235 }
    { char: \r char: \n   }
}

CHARS [ CHARS set-at ] assoc-each

: ch>flip ( ch -- ch' )
    dup CHARS at [ nip ] when* ;

PRIVATE>

: flip-text ( str -- str' )
    [ ch>flip ] map reverse ;
