! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inference
USING: inference.backend inference.dataflow
inference.known-words inference.stack inference.transforms
inference.errors sequences prettyprint io effects kernel
namespaces quotations ;

GENERIC: infer ( quot -- effect )

M: callable infer ( quot -- effect )
    [ infer-quot current-effect ] with-infer ;

: infer. ( quot -- )
    infer effect>string print ;

: (dataflow) ( quot -- dataflow )
    infer-quot
    reify-all
    f #return node,
    dataflow-graph get ;

: dataflow ( quot -- dataflow )
    [ (dataflow) ] with-infer ;

: dataflow-with ( quot stack -- dataflow )
    [ V{ } like meta-d set (dataflow) ] with-infer ;
