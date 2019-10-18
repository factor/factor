USING: effects sequences kernel arrays quotations inference
tools.test ;
IN: tools.test.inference

: short-effect
    dup effect-in length swap effect-out length 2array ;

: unit-test-effect ( effect quot -- )
    >r 1quotation r> [ infer short-effect ] curry unit-test ;
