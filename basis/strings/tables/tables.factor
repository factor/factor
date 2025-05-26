! Copyright (C) 2009, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel make math math.order sequences splitting ;
IN: strings.tables

SYMBOL: cell-format

HOOK: cell-length cell-format ( str -- n )

M: f cell-length length ;

<PRIVATE

: format-row ( seq -- seq )
    dup longest length '[ _ "" pad-tail ] map! ;

: format-column ( seq -- seq )
    dup [ cell-length ] maximum-by cell-length '[
         _ over cell-length [-]
         [ CHAR: \s <repetition> append ] unless-zero
     ] map! ;

: format-cells ( seq -- seq )
    [ [ split-lines ] map format-row flip ] map concat flip
    [ { } ] [
        [ but-last-slice [ format-column ] map! drop ] keep
    ] if-empty ;

PRIVATE>

: format-table ( table -- seq )
    format-cells flip [ join-words ] map! ;

: format-table. ( table -- )
    format-table write-lines ;

: format-box ( table -- seq )
    format-cells [ { } ] [
        dup length 1 - over [ format-column ] change-nth flip [
            [ [ " │ " join "│ " " │" surround ] map ]
            [ first [ cell-length CHAR: ─ <repetition> ] map ] bi
            [ "─┬─" join "┌─" "─┐" surround , ]
            [ "─┼─" join "├─" "─┤" surround '[ _ , ] [ , ] interleave ]
            [ "─┴─" join "└─" "─┘" surround , ] tri
        ] { } make
    ] if-empty ;

: format-box. ( table -- )
    format-box write-lines ;
