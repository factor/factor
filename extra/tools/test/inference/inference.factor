! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: effects sequences kernel arrays quotations inference
tools.test words ;
IN: tools.test.inference

: short-effect
    dup effect-in length swap effect-out length 2array ;

: unit-test-effect ( effect quot -- )
    >r 1quotation r> [ infer short-effect ] curry unit-test ;

: must-infer ( word -- )
    dup "declared-effect" word-prop
    dup effect-in length swap effect-out length 2array
    swap 1quotation unit-test-effect ;
