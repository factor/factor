IN: benchmark.compiler
USING: assocs words sequences arrays compiler tools.time
io.styles io prettyprint vocabs kernel sorting generator
optimizer ;

: recompile-with-timings
    all-words [ compiled? ] subset
    [ dup [ word-dataflow optimize nip drop ] benchmark nip ] { } map>assoc
    sort-values 20 tail*
    "Worst offenders:" print
    standard-table-style
    [
        [ [ "Word" write ] with-cell [ "Compile time (ms)" write ] with-cell ] with-row
        [ [ [ pprint-cell ] each ] with-row ] each
    ] tabular-output ;

MAIN: recompile-with-timings
