! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: io.directories kernel sequences xml ;
IN: benchmark.xml

: xml-benchmark ( -- )
    "vocab:xmode/catalog/modes/" [
        [ file>xml drop ] each
    ] with-directory-files ;

MAIN: xml-benchmark
