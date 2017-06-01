USING: io kernel math.parser sequences ui.gadgets.panes ;
IN: benchmark.ui-panes

: ui-panes-benchmark ( -- )
    [ 10000 <iota> [ number>string print ] each ] make-pane drop ;

MAIN: ui-panes-benchmark
