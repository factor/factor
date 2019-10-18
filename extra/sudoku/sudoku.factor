! Based on http://www.ffconsultancy.com/ocaml/sudoku/index.html
USING: sequences namespaces kernel math math.parser io
io.styles combinators columns ;
IN: sudoku

SYMBOL: solutions
SYMBOL: board

: pair+ ( a b c d -- a+b c+d ) swapd [ + ] 2bi@ ;

: row ( n -- row ) board get nth ;
: board> ( m n -- x ) row nth ;
: >board ( row m n -- ) row set-nth ;
: f>board ( m n -- ) f -rot >board ;

: row-any? ( n y -- ? ) row member? ;
: col-any? ( n x -- ? ) board get swap <column> member? ;
: cell-any? ( n x y i -- ? ) 3 /mod pair+ board> = ;

: box-any? ( n x y -- ? )
    [ 3 /i 3 * ] bi@
    9 iota [ [ 3dup ] dip cell-any? ] any?
    [ 3drop ] dip ;

DEFER: search

: assume ( n x y -- )
    [ >board ] 2keep [ [ 1 + ] dip search ] 2keep f>board ;

: attempt ( n x y -- )
    {
        { [ 3dup nip row-any? ] [ 3drop ] }
        { [ 3dup drop col-any? ] [ 3drop ] }
        { [ 3dup box-any? ] [ 3drop ] }
        [ assume ]
    } cond ;

: solve ( x y -- ) 9 [ 1 + 2over attempt ] each-integer 2drop ;

: board. ( board -- )
    standard-table-style [
        [
            [
                [
                    [
                        [
                            number>string write
                        ] [
                            "." write
                        ] if*
                    ] with-cell
                ] each
            ] with-row
        ] each
    ] tabular-output nl ;

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
