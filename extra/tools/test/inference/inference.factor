! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: effects sequences kernel arrays quotations inference
tools.test words ;
IN: tools.test.inference

: short-effect
    dup effect-in length swap effect-out length 2array ;

: unit-test-effect ( effect quot -- )
    >r 1quotation r> [ infer short-effect ] curry unit-test ;

: must-infer ( word/quot -- )
    dup word? [ 1quotation ] when
    [ infer drop ] curry [ ] swap unit-test ;
