! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.encodings.utf8 io.directories io.files kernel
sequences xml ;
IN: benchmark.xml

: xml-benchmark ( -- )
    "vocab:xmode/modes/" [
        [ file>xml drop ] each
    ] with-directory-files ;

MAIN: xml-benchmark
