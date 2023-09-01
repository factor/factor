USING: accessors arrays combinators.short-circuit grouping kernel lists
lists.lazy locals math math.functions math.parser math.ranges
models.product monads random sequences sets ui ui.gadgets.controls
ui.gadgets.layout models.combinators ui.gadgets.alerts vectors fry
ui.gadgets.labels shuffle ;
IN: sudokus

: row ( index -- row ) 1 + 9 / ceiling ;
: col ( index -- col ) 9 mod 1 + ;
: sq ( index -- square ) [ row ] [ col ] bi [ 3 / ceiling ] bi@ 2array ;
: near ( a pos -- ? ) { [ [ row ] same? ] [ [ col ] same? ] [ [ sq ] same? ] } 2|| ;
: nth-or-lower ( n seq -- elt ) [ length 1 - 2dup > [ nip ] [ drop ] if ] keep nth ;

:: solutions ( puzzle random? -- solutions )
    f puzzle random? [ indices [ f ] [ random? swap nth-or-lower ] if-empty ] [ index ] if
    [ :> pos
      1 9 [a,b] 80 <iota> [ pos near ] filter [ puzzle nth ] map prune diff
      [ 1array puzzle pos cut-slice rest surround ] map >list [ random? solutions ] bind
    ] [ puzzle list-monad return ] if* ;

: solution ( puzzle random? -- solution ) dupd solutions dup +nil+ = [ drop "Unsolvable" alert* ] [ nip car ] if ;
: hint ( puzzle -- puzzle' ) [ [ f swap indices random dup ] [ f solution ] bi nth ] keep swapd >vector [ set-nth ] keep ;
: create ( difficulty -- puzzle ) 81 [ f ] replicate
    40 random solution [ [ f swap [ length random ] keep set-nth ] curry times ] keep ;

: do-sudoku ( -- ) [ [
        [
            81 [ "" ] replicate <basic> switch-models [ [ <basic> ] map 9 group [ 3 group ] map 3 group
               [ [ [ <spacer> [ [ <model-field> ->% 2 [ string>number ] fmap ]
                    map <spacer> ] map concat ] <hbox> , ] map concat <spacer> ] map concat <product>
               [ "Difficulty:" <label> , "1" <basic> <model-field> -> [ string>number 1 or 1 + 10 * ] fmap
               "Generate" <model-border-btn> -> updates [ create ] fmap <spacer>
               "Hint" <model-border-btn> -> "Solve" <model-border-btn> -> ] <hbox> ,
               roll [ swap updates ] curry bi@
               [ [ hint ] fmap ] [ [ f solution ] fmap ] bi* 3array merge [ [ [ number>string ] [ "" ] if* ] map ] fmap
           ] bind
        ] with-self , ] <vbox> { 280 220 } >>pref-dim
    "Sudoku Sleuth" open-window ] with-ui ;

MAIN: do-sudoku
