! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license.
USING: assocs json.reader json.writer kernel math math.parser
sequences ;
IN: benchmark.json

: json-benchmark ( -- )
    200 <iota> [ [ number>string ] keep ] H{ } map>assoc
    1,000 [ >json json> ] times drop ;

MAIN: json-benchmark
