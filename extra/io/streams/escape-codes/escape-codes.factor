! Copyright (C) 2022 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs io.styles kernel math regexp sequences splitting
strings ;
IN: io.streams.escape-codes

<PRIVATE

CONSTANT: ansi-font-styles H{
    { bold "\e[1m" }
    { faint "\e[2m" }
    { italic "\e[3m" }
    { bold-italic "\e[1m\e[3m" }
    { underline "\e[4m" }
    { blink "\e[5m" }
}
PRIVATE>


: ansi-font-style ( font-style -- string )
    dup sequence? [
        [ ansi-font-styles at ] map concat
    ] [
        ansi-font-styles at
    ] if "" or ;

<PRIVATE

: ansi-escape-length ( str -- n )
    [ 0 ] dip >string R/ (\x9B|\x1B\[)[0-?]*[ -\/]*[@-~]/
    [ drop swap - + ] each-match ;

: ansi-length ( str -- n )
    [ length ] [ ansi-escape-length ] bi - ;

: ansi-longest ( seq -- elt )
    [ ansi-length ] maximum-by ;

: ansi-pad-tail ( seq n elt -- padded )
    [ over ansi-length - ] dip '[ _ <repetition> append ] unless-zero ;

: format-row ( seq -- seq )
    dup longest length '[ _ "" pad-tail ] map! ;

: format-ansi-column ( seq -- seq )
    dup ansi-longest ansi-length '[ _ CHAR: \s ansi-pad-tail ] map! ;

: format-ansi-cells ( seq -- seq )
    [ [ split-lines ] map format-row flip ] map concat flip
    [ { } ] [
        [ but-last-slice [ format-ansi-column ] map! drop ] keep
    ] if-empty ;

PRIVATE>

: format-ansi-table ( table -- seq )
    format-ansi-cells flip [ join-words ] map! ;
