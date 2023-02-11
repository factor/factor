! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: grouping interval-sets kernel math random sequences
sorting ;

IN: benchmark.interval-sets

: interval-sets-benchmark ( -- )
    10,000 [ random-32 ] replicate sort
    2 <groups> <interval-set>
    3,000,000 swap '[ random-32 _ interval-in? drop ] times ;

MAIN: interval-sets-benchmark
