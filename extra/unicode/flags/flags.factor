USING: ascii assocs sequences ;

IN: unicode.flags

CONSTANT: flag-codes H{
    { CHAR: A CHAR: 🇦 }
    { CHAR: B CHAR: 🇧 }
    { CHAR: C CHAR: 🇨 }
    { CHAR: D CHAR: 🇩 }
    { CHAR: E CHAR: 🇪 }
    { CHAR: F CHAR: 🇫 }
    { CHAR: G CHAR: 🇬 }
    { CHAR: H CHAR: 🇭 }
    { CHAR: I CHAR: 🇮 }
    { CHAR: J CHAR: 🇯 }
    { CHAR: K CHAR: 🇰 }
    { CHAR: L CHAR: 🇱 }
    { CHAR: M CHAR: 🇲 }
    { CHAR: N CHAR: 🇳 }
    { CHAR: O CHAR: 🇴 }
    { CHAR: P CHAR: 🇵 }
    { CHAR: Q CHAR: 🇶 }
    { CHAR: R CHAR: 🇷 }
    { CHAR: S CHAR: 🇸 }
    { CHAR: T CHAR: 🇹 }
    { CHAR: U CHAR: 🇺 }
    { CHAR: V CHAR: 🇻 }
    { CHAR: W CHAR: 🇼 }
    { CHAR: X CHAR: 🇽 }
    { CHAR: Y CHAR: 🇾 }
    { CHAR: Z CHAR: 🇿 }
}

: unicode-flag ( country-code -- flag )
    >upper [ flag-codes at ] map ;
