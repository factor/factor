! Based on http://www.ffconsultancy.com/ocaml/sudoku/index.html
USING: sequences namespaces kernel math math.parser io
io.styles combinators ;
IN: sudoku

SYMBOL: solutions
SYMBOL: board

: pair+ swapd + >r + r> ;

: row board get nth ;
: board> row nth ;
: >board row set-nth ;
: f>board f -rot >board ;

: row-contains? ( n y -- ? ) row member? ;
: col-contains? ( n x -- ? ) board get swap <column> member? ;
: cell-contains? ( n x y i -- ? ) 3 /mod pair+ board> = ;

: box-contains? ( n x y -- ? )
    [ 3 /i 3 * ] 2apply
    9 [ >r 3dup r> cell-contains? ] contains?
    >r 3drop r> ;

DEFER: search

: assume ( n x y -- )
    [ >board ] 2keep [ >r 1+ r> search ] 2keep f>board ;

: attempt ( n x y -- )
    {
        { [ 3dup nip row-contains? ] [ 3drop ] }
        { [ 3dup drop col-contains? ] [ 3drop ] }
        { [ 3dup box-contains? ] [ 3drop ] }
        { [ t ] [ assume ] }
    } cond ;

: solve ( x y -- ) 9 [ 1+ pick pick attempt ] each 2drop ;

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
    ] tabular-output ;

: solution. ( -- )
    solutions inc "Solution:" print board get board. ;

: search ( x y -- )
    {
        { [ over 9 = ] [ >r drop 0 r> 1+ search ] }
        { [ over 0 = over 9 = and ] [ 2drop solution. ] }
        { [ 2dup board> ] [ >r 1+ r> search ] }
        { [ t ] [ solve ] }
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
