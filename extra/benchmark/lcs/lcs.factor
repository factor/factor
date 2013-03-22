USING: kernel lcs math ;
IN: benchmark.lcs

: lcs-benchmark ( -- )
    f 50,000 [ drop "sitting" "kitten" levenshtein ] times 3 assert=
    f 50,000 [ drop "faxbcd" "abdef" lcs ] times "abd" assert= ;

MAIN: lcs-benchmark
