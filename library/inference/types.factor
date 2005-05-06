! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel kernel-internals
lists math namespaces strings vectors words sequences
stdio prettyprint ;

: type-value-map ( value -- )
    num-types
    [ tuck builtin-type <class-tie> cons ] project-with
    [ cdr class-tie-class ] subset ;

: value-types ( value -- list ) value-class builtin-supertypes ;

: literal-type ( -- )
    dataflow-drop, pop-d value-types car
    apply-literal ;

: computed-type ( -- )
    \ type #call dataflow, [
        peek-d type-value-map >r
        1 0 node-inputs
        [ object ] consume-d
        [ fixnum ] produce-d
        r> peek-d set-value-literal-ties
        1 0 node-outputs
    ] bind ;

\ type [
    [ object ] ensure-d
    literal-type? [ literal-type ] [ computed-type ] ifte
] "infer" set-word-prop
