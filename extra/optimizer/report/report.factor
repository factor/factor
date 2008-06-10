USING: assocs words sequences arrays compiler tools.time
io.styles io prettyprint vocabs kernel sorting generator
optimizer math math.order ;
IN: optimizer.report

: count-optimization-passes ( nodes n -- n )
    >r optimize-1
    [ r> 1+ count-optimization-passes ] [ drop r> ] if ;

: results ( seq -- )
    [ [ second ] prepose compare ] curry sort 20 tail*
    print
    standard-table-style
    [
        [ [ [ pprint-cell ] each ] with-row ] each
    ] tabular-output ;

: optimizer-report ( -- )
    all-words [ compiled? ] filter
    [
        dup [
            word-dataflow nip 1 count-optimization-passes
        ] benchmark 2array
    ] { } map>assoc
    [ first ] "Worst number of optimizer passes:" results
    [ second ] "Worst compile times:" results ;

MAIN: optimizer-report
