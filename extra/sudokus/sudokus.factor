USING: accessors arrays combinators.short-circuit fry grouping
kernel lists lists.lazy locals math math.functions math.parser
models.combinators models.product monads random ranges sequences
sets shuffle ui ui.gadgets.alerts ui.gadgets.controls
ui.gadgets.labels ui.gadgets.layout vectors ;
IN: sudokus

: row ( index -- row ) 1 + 9 / ceiling ;
: col ( index -- col ) 9 mod 1 + ;
: sq ( index -- square ) [ row ] [ col ] bi [ 3 / ceiling ] bi@ 2array ;
: near ( a pos -- ? ) { [ [ row ] same? ] [ [ col ] same? ] [ [ sq ] same? ] } 2|| ;
: nth-or-lower ( n seq -- elt ) [ length 1 - 2dup > [ nip ] [ drop ] if ] keep nth ;

:: solutions ( puzzle random? -- solutions )
    f puzzle random? [
        indices [ f ] [ random? swap nth-or-lower ] if-empty
    ] [ index ] if [| pos |
        1 9 [a..b] 80 <iota> [ pos near ] filter
        [ puzzle nth ] map members diff
        [ 1array puzzle pos cut-slice rest surround ] map >list
        [ random? solutions ] bind
    ] [ puzzle list-monad return ] if* ;

: solution ( puzzle random? -- solution )
    dupd solutions dup +nil+ = [ drop "Unsolvable" alert* ] [ nip car ] if ;

: hint ( puzzle -- puzzle' )
    f over indices random [
        [ >vector dup f solution ]
        [ [ swap nth ] keep pick set-nth ] bi*
    ] when* ;

: create ( difficulty -- puzzle )
    81 f <array>
    40 random solution [
        [ f swap [ length random ] keep set-nth ] curry times
    ] keep ;

: <sudoku-gadget> ( -- gadget )
    [
        [
            81 [ "" ] replicate <basic> switch-models [
                [ <basic> ] map 9 group [ 3 group ] map 3 group
                [
                    [
                        [
                            <spacer> [
                                [ <model-field> ->% 2 [ string>number ] fmap ] map <spacer>
                            ] map concat
                        ] <hbox> ,
                    ] map concat <spacer>
                ] map concat <product>
                [
                    "Difficulty:" <label> , "1" <basic> <model-field> -> [ string>number 1 or 1 + 10 * ] fmap
                    "Generate" <model-border-btn> -> updates [ create ] fmap <spacer>
                    "Hint" <model-border-btn> -> "Solve" <model-border-btn> ->
                ] <hbox> , roll [ swap updates ] curry bi@
                [ [ hint ] fmap ] [ [ f solution ] fmap ] bi* 3array merge
                [ [ [ number>string ] [ "" ] if* ] map ] fmap
           ] bind
        ] with-self ,
    ] <vbox> { 280 220 } >>pref-dim ;

MAIN-WINDOW: sudoku-main
    { { title "Sudoku Sleuth" } }
    <sudoku-gadget> >>gadgets ;
