
USING: kernel continuations arrays assocs sequences sorting math
       io io.styles prettyprint builder.util ;

IN: builder.benchmark

: passing-benchmarks ( table -- table )
  [ second first2 number? swap number? and ] subset ;

: simplify-table ( table -- table ) [ first2 second 2array ] map ;

: benchmark-difference ( old-table benchmark-result -- result-diff )
  first2 >r
  tuck swap at
  r>
  swap -
  2array ;

: compare-tables ( old new -- table )
  [ passing-benchmarks simplify-table ] 2apply
  [ benchmark-difference ] with map ;

: benchmark-deltas ( -- table )
  "../benchmarks" "benchmarks" [ eval-file ] 2apply
  compare-tables
  sort-values ;

: benchmark-deltas. ( deltas -- )
  standard-table-style
    [
      [ [ "Benchmark" write ] with-cell [ "Delta (ms)" write ] with-cell ]
      with-row
      [ [ swap [ write ] with-cell pprint-cell ] with-row ]
      assoc-each
    ]
  tabular-output ;

: show-benchmark-deltas ( -- )
  [ benchmark-deltas benchmark-deltas. ]
    [ drop "Error generating benchmark deltas" . ]
  recover ;