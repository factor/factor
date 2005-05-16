! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: generic interpreter kernel lists math namespaces words ;

: type-value-map ( value -- )
    num-types
    [ tuck builtin-type <class-tie> cons ] project-with
    [ cdr class-tie-class ] subset ;

: infer-type ( -- )
    f \ type dataflow, [
        peek-d type-value-map >r
        1 0 node-inputs
        [ object ] consume-d
        [ fixnum ] produce-d
        r> peek-d set-value-literal-ties
        1 0 node-outputs
    ] bind ;

: type-known? ( value -- ? )
    dup value-safe? swap value-types cdr not and ;

\ type [
    peek-d type-known? [
        1 dataflow-drop, pop-d value-types car apply-literal
    ] [
        infer-type
    ] ifte
] "infer" set-word-prop
