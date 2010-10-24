USING: io math.parser sequences ui.gadgets.panes ;
IN: benchmark.ui-panes

: ui-pane-benchmark ( -- )
    <pane> <pane-stream> [ 10000 iota [ number>string print ] each ] with-output-stream* ;

MAIN: ui-pane-benchmark
