! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: inference.backend inference.dataflow
inference.known-words inference.transforms inference.errors
sequences prettyprint io effects kernel namespaces quotations ;

GENERIC: infer ( quot -- effect )

M: callable infer ( quot -- effect )
    [ f infer-quot ] with-infer drop ;

: infer. ( quot -- )
    infer effect>string print ;

GENERIC: dataflow ( quot -- dataflow )

M: callable dataflow
    [ f infer-quot ] with-infer nip ;

GENERIC# dataflow-with 1 ( quot stack -- dataflow )

M: callable dataflow-with
    [
        V{ } like meta-d set
        f infer-quot
    ] with-infer nip ;
