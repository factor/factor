USING: accessors assocs biassocs countries kernel lexer
prettyprint sequences unicode ;

IN: unicode.flags

MEMO: flag-codes ( -- biassoc ) H{
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
} >biassoc ;

: unicode>flag ( country-code -- flag )
    >upper [ flag-codes from>> at ] map ;

: flag>unicode ( flag -- country-code )
    [ flag-codes to>> at ] map ;

: country>flag ( country-name -- flag )
    alpha-2 ?value-at drop unicode>flag ;

: flag>country ( flag -- country-name )
    flag>unicode alpha-2 ?at drop ;

! Random flags, England/Scotland/Wales, Refugee Nation Flag
CONSTANT: extra-flags { "🏁" "🚩" "🎌" "🏴" "🏳" "🏳️‍🌈" "🏴‍☠️" "🏴󠁧󠁢󠁥󠁮󠁧󠁿" "🏴󠁧󠁢󠁳󠁣󠁴󠁿" "🏴󠁧󠁢󠁷󠁬󠁳󠁿" "🏳️‍🟧‍⬛️‍🟧" }

: explain-extra-flags ( -- )
    extra-flags [
        dup . [ dup char>name ] { } map>assoc .
    ] each ;


SYNTAX: FLAG: scan-token unicode>flag suffix! ;
