USING: accessors arrays combinators.short-circuit grouping kernel lists
lists.lazy locals math math.functions math.parser math.ranges
models.product monads random sequences sets ui ui.frp.gadgets
ui.frp.layout ui.frp.signals ui.gadgets.alerts vectors ;
IN: gui-sudoku

: row ( index -- row ) 1 + 9 / ceiling ;
: col ( index -- col ) 9 mod 1 + ;
: sq ( index -- square ) [ row ] [ col ] bi [ 3 / ceiling ] bi@ 2array ;
: near ( a pos -- ? ) { [ [ row ] bi@ = ] [ [ col ] bi@ = ] [ [ sq ] bi@ = ] } 2|| ;
MEMO:: solutions ( puzzle -- solutions )
    f puzzle index
    [ :> pos
      1 9 [a,b] 80 iota [ pos near ] filter [ puzzle nth ] map prune diff
      [ 1array puzzle pos cut-slice rest surround ] map >list [ solutions ] bind
    ] [ puzzle list-monad return ] if* ;

: solution ( puzzle -- solution ) dup solutions dup +nil+ = [ drop "Unsolvable" alert* ] [ nip car ] if ;
: hint ( puzzle -- puzzle' ) [ [ f swap indices random dup ] [ solution ] bi nth ] keep swapd >vector [ set-nth ] keep ;

: do-sudoku ( -- ) [ [ [ $ SUDOKU $ ] <vbox> { 280 220 } >>pref-dim
        [
            81 [ "" ] replicate <basic> <switch> [ SUDOKU [ <basic> ] map 9 group [ 3 group ] map 3 group
               [ [ [ <spacer> [ [ <frp-field> ->% 2 [ string>number ] fmap ]
                    map <spacer> ] map concat ] <hbox> , ] map concat <spacer> ] map concat <product> dup
               [ "Hint" <frp-border-button> -> "Solve" <frp-border-button> -> ] <hbox> , swapd [ <updates> ] 2bi@
               [ [ hint ] fmap ] [ [ solution ] fmap ] bi* <2merge> [ [ [ number>string ] [ "" ] if* ] map ] fmap
           ] bind
        ] with-self SUDOKU ,
    ] with-interface "Sudoku Sleuth" open-window ] with-ui ;

MAIN: do-sudoku