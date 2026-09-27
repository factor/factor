! Copyright (C) 2026 John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: concurrency.combinators kernel ranges sequences ;
IN: benchmark.tasks

! Create and complete 5.5 million tasks, retaining each group until it runs.
: tasks-benchmark ( -- )
    100,000 1,000,000 100,000 <range>
    [ <iota> [ ] parallel-map drop ] each ;

MAIN: tasks-benchmark
