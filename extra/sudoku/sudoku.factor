! Based on http://www.ffconsultancy.com/ocaml/sudoku/index.html
USING: columns combinators combinators.short-circuit generalizations io
io.styles kernel math math.parser namespaces sequences ;
IN: sudoku

SYMBOL: solutions
SYMBOL: board

: pair+ ( a b c d -- a+b c+d ) swapd [ + ] 2bi@ ;

: row ( n -- row ) board get nth ;
: board> ( m n -- x ) row nth ;
: >board ( row m n -- ) row set-nth ;

: row-any? ( n y -- ? ) row member? ;
: col-any? ( n x -- ? ) board get swap <column> member? ;
: cell-any? ( n x y i -- ? ) 3 /mod pair+ board> = ;

: box-any? ( n x y -- ? )
    [ 3 /i 3 * ] bi@ 9 <iota> [ cell-any? ] 3 nwith any? ;

: board-any? ( n x y -- ? )
    { [ nip row-any? ] [ drop col-any? ] [ box-any? ] } 3|| ;

DEFER: search

: assume ( n x y -- )
    [ >board ] [ [ 1 + ] dip search f ] [ >board ] 2tri ;

: attempt ( n x y -- )
    3dup board-any? [ 3drop ] [ assume ] if ;

: solve ( x y -- )
    9 [ 1 + 2over attempt ] each-integer 2drop ;

: cell. ( cell -- )
    [ [ number>string write ] [ "." write ] if* ] with-cell ;

: row. ( row -- )
    [ [ cell. ] each ] with-row ;

: board. ( board -- )
    standard-table-style [ [ row. ] each ] tabular-output nl ;

: solution. ( -- )
    solutions inc "Solution:" print board get board. ;

: search ( x y -- )
    {
        { [ over 9 = ] [ [ drop 0 ] dip 1 + search ] }
        { [ over 0 = over 9 = and ] [ 2drop solution. ] }
        { [ 2dup board> ] [ [ 1 + ] dip search ] }
        [ solve ]
    } cond ;

: sudoku ( board -- )
    [
        "Puzzle:" print dup board.

        0 solutions set
        [ clone ] map board set

        0 0 search

        solutions get number>string write " solutions." print
    ] with-scope ;

: sudoku-demo ( -- )
    {
        { f f 1 f f 5 3 f f }
        { f 5 f 4 9 f f f f }
        { f f f 1 f 2 f 6 4 }
        { f f f f f f 7 5 f }
        { 6 f f f f f f f 1 }
        { f 3 5 f f f f f f }
        { 4 6 f 9 f 3 f f f }
        { f f f f 2 4 f 9 f }
        { f f 3 6 f f 1 f f }
    } sudoku ;

MAIN: sudoku-demo
