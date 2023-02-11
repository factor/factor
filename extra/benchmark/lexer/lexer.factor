! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: io.encodings.ascii io.files kernel lexer math ;

IN: benchmark.lexer

: lexer-benchmark ( -- )
    10,000 "vocab:math/math.factor" ascii file-lines [
        <lexer> [ parse-token ] curry loop
    ] curry times ;

MAIN: lexer-benchmark
