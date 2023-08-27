! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math ranges math.order math.parser
io sequences ;
IN: benchmark.binary-trees

TUPLE: tree-node item left right ;

C: <tree-node> tree-node

: bottom-up-tree ( item depth -- tree )
    dup 0 > [
        1 -
        [ drop ]
        [ [ 2 * 1 - ] dip bottom-up-tree ]
        [ [ 2 *     ] dip bottom-up-tree ] 2tri
    ] [
        drop f f
    ] if <tree-node> ; inline recursive

GENERIC: item-check ( node -- n )

M: tree-node item-check
    [ item>> ] [ left>> ] [ right>> ] tri [ item-check ] bi@ - + ;

M: f item-check drop 0 ;

CONSTANT: min-depth 4

: stretch-tree ( max-depth -- )
    1 + 0 over bottom-up-tree item-check
    [ "stretch tree of depth " write number>string write ]
    [ "\t check: " write number>string print ] bi* ; inline

:: long-lived-tree ( max-depth -- )
    0 max-depth bottom-up-tree

    min-depth max-depth 2 <range> [| depth |
        max-depth depth - min-depth + 2^ [
            [1..b] 0 [
                dup neg
                [ depth bottom-up-tree item-check + ] bi@
            ] reduce
        ]
        [ 2 * number>string write ] bi
        "\t trees of depth " write depth number>string write
        "\t check: " write number>string print
    ] each

    "long lived tree of depth " write max-depth number>string write
    "\t check: " write item-check number>string print ; inline

: binary-trees ( n -- )
    min-depth 2 + max [ stretch-tree ] [ long-lived-tree ] bi ; inline

: binary-trees-benchmark ( -- )
    16 binary-trees ;

MAIN: binary-trees-benchmark
