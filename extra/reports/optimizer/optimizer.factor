! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs words sequences arrays compiler
tools.time io.styles io prettyprint vocabs kernel sorting
generator optimizer math math.order math.statistics combinators
optimizer.debugger ;
IN: report.optimizer

: table. ( alist -- )
    20 short tail*
    standard-table-style
    [
        [ [ [ pprint-cell ] each ] with-row ] each
    ] tabular-output ;

: results ( results quot title -- )
    print
    [ second ] prepose
    [ [ compare ] curry sort table. ]
    [
        map
        [ "Mean: " write mean >float . ]
        [ "Median: " write median >float . ]
        [ "Standard deviation: " write std >float . ]
        tri
    ] 2bi ; inline

: optimization-passes ( word -- n )
    word-dataflow nip 1 count-optimization-passes nip ;

: optimizer-measurements ( -- alist )
    all-words [ compiled>> ] filter
    [ dup [ optimization-passes ] benchmark 2array ] { } map>assoc ;

: optimizer-measurements. ( alist -- )
    {
        [ [ first ] "Optimizer passes:" results ]
        [ [ second ] "Compile times:" results ]
    } cleave ;

: optimizer-report ( -- )
    optimizer-measurements optimizer-measurements. ;

MAIN: optimizer-report
