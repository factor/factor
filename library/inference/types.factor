! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: inference
USING: errors generic interpreter kernel kernel-internals
lists math namespaces strings vectors words stdio prettyprint ;

! Enhanced inference of primitives relating to data types.
! Optimizes type checks and slot access.

: infer-check ( assert class -- )
    peek-d dup value-class pick = [
        3drop
    ] [
        value-class-and
        dup "infer-effect" word-property consume/produce
    ] ifte ;

\ >cons [
    \ >cons \ cons infer-check
] "infer" set-word-property

\ >vector [
    \ >vector \ vector infer-check
] "infer" set-word-property

\ >string [
    \ >string \ string infer-check
] "infer" set-word-property

! \ slot [
!     [ object fixnum ] ensure-d
!     dataflow-drop, pop-d value-literal
!     peek-d value-class builtin-supertypes dup length 1 = [
!         cons \ slot [ [ object ] [ object ] ] (consume/produce)
!     ] [
!         "slot called without static type knowledge" throw
!     ] ifte
! ] "infer" set-word-property

: type-value-map ( value -- )
    num-types [ dup builtin-type pick swons cons ] project
    [ cdr cdr ] subset nip ;

\ type [
    [ object ] ensure-d
    \ type #call dataflow, [
        peek-d type-value-map >r
        1 0 node-inputs
        [ object ] consume-d
        [ fixnum ] produce-d
        r> peek-d value-type-prop
        1 0 node-outputs
    ] bind
] "infer" set-word-property
