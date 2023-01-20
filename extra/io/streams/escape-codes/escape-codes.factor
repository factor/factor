! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs io.styles kernel sequences ;
IN: io.streams.escape-codes

CONSTANT: font-style-assoc H{
    { bold "\e[1m" }
    { faint "\e[2m" }
    { italic "\e[3m" }
    { bold-italic "\e[1m\e[3m" }
    { underline "\e[4m" }
    { blink "\e[5m" }
}

: font-styles ( font-style -- string )
    dup sequence? [
        [ font-style-assoc at ] map concat
    ] [
        font-style-assoc at
    ] if "" or ;
