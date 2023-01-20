! Copyright (C) 2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license.
USING: arrays csv kernel math.parser sequences ;
IN: benchmark.csv

: csv-benchmark ( -- )
    1,000 200 <iota> [ number>string ] map <array>
    [ csv>string string>csv ] keep assert= ;

MAIN: csv-benchmark
