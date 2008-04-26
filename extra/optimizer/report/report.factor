IN: optimizer.report
USING: assocs words sequences arrays compiler tools.time
io.styles io prettyprint vocabs kernel sorting generator
optimizer math ;

: count-optimization-passes ( nodes n -- n )
    >r optimize-1
    [ r> 1+ count-optimization-passes ] [ drop r> ] if ;

: results
    [ [ second ] prepose compare ] curry sort 20 tail*
    print
    standard-table-style
    [
        [ [ [ pprint-cell ] each ] with-row ] each
    ] tabular-output ;

: optimizer-report
    all-words [ compiled? ] filter
    [
        dup [
            word-dataflow nip 1 count-optimization-passes
        ] benchmark nip 2array
    ] { } map>assoc
    [ first ] "Worst number of optimizer passes:" results
    [ second ] "Worst compile times:" results ;

MAIN: optimizer-report
