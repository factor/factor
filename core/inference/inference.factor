! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: inference.backend inference.state inference.dataflow
inference.known-words inference.transforms inference.errors
kernel io effects namespaces sequences quotations vocabs
generic words ;
IN: inference

GENERIC: infer ( quot -- effect )

M: callable infer ( quot -- effect )
    [ recursive-state get infer-quot ] with-infer drop ;

: infer. ( quot -- )
    #! Safe to call from inference transforms.
    infer effect>string print ;

GENERIC: dataflow ( quot -- dataflow )

M: callable dataflow
    #! Not safe to call from inference transforms.
    [ f infer-quot ] with-infer nip ;

GENERIC# dataflow-with 1 ( quot stack -- dataflow )

M: callable dataflow-with
    #! Not safe to call from inference transforms.
    [
        V{ } like meta-d set
        f infer-quot
    ] with-infer nip ;

: forget-errors ( -- )
    all-words [
        dup subwords [ f "cannot-infer" set-word-prop ] each
        f "cannot-infer" set-word-prop
    ] each ;
